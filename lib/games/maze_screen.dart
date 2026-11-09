import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/maze_logic.dart';

class MazeScreen extends StatefulWidget {
  const MazeScreen({super.key});

  @override
  State<MazeScreen> createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen> {
  final _rand = Random();
  final _watch = Stopwatch();
  Timer? _ticker;
  Difficulty _difficulty = Difficulty.easy;
  late Maze _maze;
  int _px = 0, _py = 0, _moves = 0;
  bool _won = false;
  bool _newRecord = false;
  double _dragX = 0, _dragY = 0;
  bool _locked = false; // blocca lo scroll della pagina mentre si scorre nel labirinto

  /// Dimensione del labirinto in base alla difficoltà.
  static int sizeFor(Difficulty d) => const {
        Difficulty.easy: 8,
        Difficulty.medium: 14,
        Difficulty.hard: 22,
      }[d]!;

  String get _bestKey => 'maze_${_difficulty.name}';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _newGame() {
    _ticker?.cancel();
    _watch
      ..stop()
      ..reset();
    final n = sizeFor(_difficulty);
    _maze = Maze.generate(n, n, _rand);
    _px = 0;
    _py = 0;
    _moves = 0;
    _won = false;
    _newRecord = false;
    if (mounted) setState(() {});
  }

  Future<void> _move(int dir) async {
    if (_won || !_maze.canMove(_px, _py, dir)) return;
    if (!_watch.isRunning) {
      _watch.start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() {
      if (dir == Maze.n) _py--;
      if (dir == Maze.s) _py++;
      if (dir == Maze.e) _px++;
      if (dir == Maze.w) _px--;
      _moves++;
    });
    if (_px == _maze.cols - 1 && _py == _maze.rows - 1) {
      _watch.stop();
      _ticker?.cancel();
      final record = await GameStats.instance.submitBest(_bestKey, _watch.elapsedMilliseconds);
      if (mounted) {
        setState(() {
          _won = true;
          _newRecord = record;
        });
      }
    }
  }

  void _onPan(DragUpdateDetails d, double cell) {
    _dragX += d.delta.dx;
    _dragY += d.delta.dy;
    final thr = cell * 0.6;
    if (_dragX.abs() > thr && _dragX.abs() >= _dragY.abs()) {
      _move(_dragX > 0 ? Maze.e : Maze.w);
      _dragX = 0;
      _dragY = 0;
    } else if (_dragY.abs() > thr) {
      _move(_dragY > 0 ? Maze.s : Maze.n);
      _dragX = 0;
      _dragY = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_bestKey);
    return GameScaffold(
      title: l.gameMaze,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
      children: [
        DifficultyChips(value: _difficulty, onChanged: (d) {
          _difficulty = d;
          _newGame();
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtTime(_watch.elapsedMilliseconds),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(l.gameMoves(_moves)),
            Text(best == null ? l.gameNoRecord : l.gameBest(fmtTime(best))),
          ],
        ),
        const SizedBox(height: 8),
        if (_won)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l.gameMazeHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
        LayoutBuilder(builder: (context, box) {
          final side = box.maxWidth;
          final cell = side / _maze.cols;
          return Listener(
            onPointerDown: (_) => setState(() => _locked = true),
            onPointerUp: (_) => setState(() => _locked = false),
            onPointerCancel: (_) => setState(() => _locked = false),
            child: GestureDetector(
              onPanStart: (_) {
                _dragX = 0;
                _dragY = 0;
              },
              onPanUpdate: (d) => _onPan(d, cell),
              child: SizedBox(
                width: side,
                height: side,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(side, side),
                      painter: _MazePainter(_maze, scheme.onSurface, scheme.primaryContainer),
                    ),
                    // Il bus del logo dell'app
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 90),
                      left: _px * cell,
                      top: _py * cell,
                      width: cell,
                      height: cell,
                      child: Padding(
                        padding: EdgeInsets.all(cell * 0.08),
                        child: Image.asset('assets/images/logo_bus.png', fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              IconButton.filledTonal(
                  onPressed: () => _move(Maze.n), icon: const Icon(Icons.keyboard_arrow_up_rounded)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                      onPressed: () => _move(Maze.w), icon: const Icon(Icons.keyboard_arrow_left_rounded)),
                  const SizedBox(width: 48),
                  IconButton.filledTonal(
                      onPressed: () => _move(Maze.e), icon: const Icon(Icons.keyboard_arrow_right_rounded)),
                ],
              ),
              IconButton.filledTonal(
                  onPressed: () => _move(Maze.s), icon: const Icon(Icons.keyboard_arrow_down_rounded)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _newGame,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l.gameNew),
        ),
      ],
    );
  }
}

class _MazePainter extends CustomPainter {
  final Maze maze;
  final Color wall;
  final Color bg;
  _MazePainter(this.maze, this.wall, this.bg);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / maze.cols;
    canvas.drawRect(Offset.zero & size, Paint()..color = bg.withOpacity(0.35));
    final paint = Paint()
      ..color = wall
      ..strokeWidth = max(1.5, cell * 0.08)
      ..strokeCap = StrokeCap.round;
    for (var y = 0; y < maze.rows; y++) {
      for (var x = 0; x < maze.cols; x++) {
        final o = maze.open[y * maze.cols + x];
        final x0 = x * cell, y0 = y * cell;
        if ((o & Maze.n) == 0) canvas.drawLine(Offset(x0, y0), Offset(x0 + cell, y0), paint);
        if ((o & Maze.w) == 0) canvas.drawLine(Offset(x0, y0), Offset(x0, y0 + cell), paint);
        if (y == maze.rows - 1) canvas.drawLine(Offset(x0, y0 + cell), Offset(x0 + cell, y0 + cell), paint);
        if (x == maze.cols - 1) canvas.drawLine(Offset(x0 + cell, y0), Offset(x0 + cell, y0 + cell), paint);
      }
    }
    final tp = TextPainter(
      text: TextSpan(text: '🏁', style: TextStyle(fontSize: cell * 0.7)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((maze.cols - 1) * cell + (cell - tp.width) / 2,
          (maze.rows - 1) * cell + (cell - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MazePainter old) => old.maze != maze || old.wall != wall;
}

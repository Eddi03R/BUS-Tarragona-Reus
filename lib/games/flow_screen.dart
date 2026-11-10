import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/flow_logic.dart';

const _flowColors = [
  Color(0xFFEF5350), Color(0xFF42A5F5), Color(0xFF66BB6A), Color(0xFFFFC107),
  Color(0xFFAB47BC), Color(0xFFFF7043), Color(0xFF26C6DA), Color(0xFFEC407A),
];

/// Collega i punti: unisci le coppie dello stesso colore senza incroci.
/// Difficoltà = dimensione della griglia e numero di colori.
class FlowScreen extends StatefulWidget {
  final Difficulty difficulty;
  const FlowScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  final _rand = Random();
  final _watch = Stopwatch();
  Timer? _ticker;
  late FlowPuzzle _puzzle;
  late FlowBoard _board;
  bool _won = false;
  bool _newRecord = false;
  bool _locked = false;
  int _gen = 0;

  String get _key => 'flow_${widget.difficulty.name}';

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
    setState(() {
      _puzzle = FlowPuzzle.generate(widget.difficulty.index, _rand);
      _board = FlowBoard(_puzzle);
      _won = false;
      _newRecord = false;
      _gen++;
    });
  }

  int? _cellAt(Offset p, double side) {
    final n = _puzzle.n;
    final cell = side / n;
    final x = (p.dx / cell).floor(), y = (p.dy / cell).floor();
    if (x < 0 || y < 0 || x >= n || y >= n) return null;
    return y * n + x;
  }

  void _start() {
    if (!_watch.isRunning && !_won) {
      _watch.start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _end() async {
    _board.end();
    setState(() => _locked = false);
    // Si vince solo quando le linee coprono tutti i riquadri.
    if (_board.perfect && !_won) {
      _watch.stop();
      _ticker?.cancel();
      final record = await GameStats.instance.submitBest(_key, _watch.elapsedMilliseconds);
      if (mounted) {
        setState(() {
          _won = true;
          _newRecord = record;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_key);
    final connected = [
      for (var c = 0; c < _puzzle.endpoints.length; c++)
        _board.paths[c].length > 1 &&
            ((_board.paths[c].first == _puzzle.endpoints[c].$1 && _board.paths[c].last == _puzzle.endpoints[c].$2) ||
                (_board.paths[c].first == _puzzle.endpoints[c].$2 && _board.paths[c].last == _puzzle.endpoints[c].$1))
    ].where((v) => v).length;
    return GameScaffold(
      title: l.gameFlow,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
      guardBack: true,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtTime(_watch.elapsedMilliseconds),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('$connected / ${_puzzle.endpoints.length}'),
            Text(best == null ? l.gameNoRecord : l.gameBest(fmtTime(best))),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: ValueKey('won-$_gen'),
                  text: _newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin,
                  kind: ResultKind.win,
                )
              : _board.solved && _board.active == null
                  ? Text(l.gameFlowFillAll,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.primary))
                  : Text(l.gameFlowHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        LayoutBuilder(builder: (context, box) {
          final side = min(box.maxWidth, 420.0);
          return Center(
            child: Listener(
              onPointerDown: (_) => setState(() => _locked = true),
              onPointerUp: (_) => _end(),
              onPointerCancel: (_) => _end(),
              child: GestureDetector(
                onPanStart: (d) {
                  final c = _cellAt(d.localPosition, side);
                  if (c == null || _won) return;
                  _start();
                  setState(() => _board.begin(c));
                },
                onPanUpdate: (d) {
                  final c = _cellAt(d.localPosition, side);
                  if (c == null || _won) return;
                  setState(() => _board.extend(c));
                },
                child: SizedBox(
                  width: side,
                  height: side,
                  child: CustomPaint(
                    painter: _FlowPainter(_board, scheme.surfaceContainerHighest, scheme.onSurface),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

class _FlowPainter extends CustomPainter {
  final FlowBoard board;
  final Color bg;
  final Color ink;
  _FlowPainter(this.board, this.bg, this.ink);

  @override
  void paint(Canvas canvas, Size size) {
    final n = board.puzzle.n;
    final cell = size.width / n;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)), Paint()..color = bg);
    final grid = Paint()
      ..color = ink.withOpacity(0.12)
      ..strokeWidth = 1;
    for (var i = 1; i < n; i++) {
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), grid);
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), grid);
    }
    // I riquadri coperti da una linea si colorano: si vede subito cosa manca.
    for (var c = 0; c < board.paths.length; c++) {
      final tint = Paint()..color = _flowColors[c % _flowColors.length].withOpacity(0.22);
      for (final k in board.paths[c]) {
        canvas.drawRect(
            Rect.fromLTWH((k % n) * cell + 1, (k ~/ n) * cell + 1, cell - 2, cell - 2), tint);
      }
    }
    Offset center(int cellIdx) => Offset((cellIdx % n + 0.5) * cell, (cellIdx ~/ n + 0.5) * cell);
    for (var c = 0; c < board.paths.length; c++) {
      final color = _flowColors[c % _flowColors.length];
      final path = board.paths[c];
      if (path.length > 1) {
        final p = Path()..moveTo(center(path.first).dx, center(path.first).dy);
        for (final k in path.skip(1)) {
          p.lineTo(center(k).dx, center(k).dy);
        }
        canvas.drawPath(
          p,
          Paint()
            ..color = color.withOpacity(0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.42
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
      final (a, b) = board.puzzle.endpoints[c];
      for (final e in [a, b]) {
        canvas.drawCircle(center(e), cell * 0.3, Paint()..color = color);
        canvas.drawCircle(center(e), cell * 0.12, Paint()..color = Colors.white.withOpacity(0.5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlowPainter old) => true;
}

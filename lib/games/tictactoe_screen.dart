import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/tictactoe_logic.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  final _rand = Random();
  Difficulty _difficulty = Difficulty.medium;
  List<Mark> _board = List.filled(9, Mark.none);
  bool _thinking = false;
  Mark _winner = Mark.none;
  bool _draw = false;

  bool get _over => _winner != Mark.none || _draw;

  void _newGame() => setState(() {
        _board = List.filled(9, Mark.none);
        _winner = Mark.none;
        _draw = false;
        _thinking = false;
      });

  void _checkEnd() {
    _winner = TicTacToeLogic.winner(_board);
    _draw = _winner == Mark.none && TicTacToeLogic.isFull(_board);
  }

  Future<void> _tap(int i) async {
    if (_over || _thinking || _board[i] != Mark.none) return;
    setState(() {
      _board[i] = Mark.x;
      _checkEnd();
      _thinking = !_over;
    });
    if (_over) return;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final smart = _difficulty == Difficulty.hard ||
        (_difficulty == Difficulty.medium && _rand.nextBool());
    final move = smart
        ? TicTacToeLogic.bestMove(List<Mark>.from(_board), Mark.o)
        : TicTacToeLogic.randomMove(_board, _rand);
    setState(() {
      _board[move] = Mark.o;
      _checkEnd();
      _thinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final status = _winner == Mark.x
        ? l.gameYouWin
        : _winner == Mark.o
            ? l.gameYouLose
            : _draw
                ? l.gameDraw
                : _thinking
                    ? l.gameThinking
                    : l.gameYourTurn;
    return GameScaffold(
      title: l.gameTicTacToe,
      children: [
        DifficultyChips(value: _difficulty, onChanged: (d) {
          _difficulty = d;
          _newGame();
        }),
        const SizedBox(height: 16),
        Center(
          child: Text(status,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(builder: (context, box) {
            final side = box.maxWidth;
            const gap = 8.0;
            final cell = (side - 2 * gap) / 3;
            Offset center(int i) => Offset(
                  (i % 3) * (cell + gap) + cell / 2,
                  (i ~/ 3) * (cell + gap) + cell / 2,
                );
            final line = TicTacToeLogic.winningLine(_board);
            return Stack(
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: gap,
                  crossAxisSpacing: gap,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < 9; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _tap(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _board[i] == Mark.x ? 'X' : _board[i] == Mark.o ? 'O' : '',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: _board[i] == Mark.x ? scheme.primary : scheme.secondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Linea sul tris, che si disegna da un estremo all'altro.
                if (line != null)
                  IgnorePointer(
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(line.join()),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 450),
                      builder: (context, t, _) => CustomPaint(
                        size: Size(side, side),
                        painter: _WinLinePainter(
                          center(line.first),
                          center(line.last),
                          t,
                          _winner == Mark.x ? Colors.green.shade700 : Colors.red.shade700,
                          cell * 0.12,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _newGame,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l.gameNew),
        ),
      ],
    );
  }
}

class _WinLinePainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final double progress;
  final Color color;
  final double width;
  _WinLinePainter(this.from, this.to, this.progress, this.color, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    // Estende la linea oltre i centri delle celle estreme.
    final dir = (to - from);
    final len = dir.distance;
    final unit = Offset(dir.dx / len, dir.dy / len);
    final extra = width * 3;
    final a = from - unit * extra;
    final b = to + unit * extra;
    canvas.drawLine(
      a,
      Offset.lerp(a, b, progress)!,
      Paint()
        ..color = color.withOpacity(0.9)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WinLinePainter old) => old.progress != progress;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/game2048_logic.dart';

/// 2048: scorri per unire i numeri uguali. Difficoltà = dimensione della griglia
/// (facile 5×5, medio 4×4, difficile 3×3).
class Game2048Screen extends StatefulWidget {
  final Difficulty difficulty;
  const Game2048Screen({super.key, this.difficulty = Difficulty.medium});

  static int sizeFor(Difficulty d) => const [5, 4, 3][d.index];

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  final _rand = Random();
  late Game2048 _game;
  bool _locked = false;
  bool _swiped = false;
  Offset _accum = Offset.zero;
  bool _reached = false; // ha raggiunto 2048 (si può continuare)
  bool _over = false;
  bool _newRecord = false;
  int _gen = 0;

  int get _size => Game2048Screen.sizeFor(widget.difficulty);
  String get _key => '2048_$_size';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _game = Game2048(_size, _rand);
      _reached = false;
      _over = false;
      _newRecord = false;
      _gen++;
    });
  }

  Future<void> _swipe(Dir2048 d) async {
    if (_over) return;
    final moved = _game.move(d);
    if (!moved) return;
    setState(() {
      if (_game.maxTile >= 2048) _reached = true;
      _over = !_game.canMove;
    });
    final record = await GameStats.instance.submitHigh(_key, _game.score);
    if (mounted && (_over || _reached)) setState(() => _newRecord = _newRecord || record);
  }

  void _pan(DragUpdateDetails d) {
    if (_swiped) return;
    _accum += d.delta;
    if (_accum.distance < 26) return;
    _swiped = true;
    if (_accum.dx.abs() > _accum.dy.abs()) {
      _swipe(_accum.dx > 0 ? Dir2048.right : Dir2048.left);
    } else {
      _swipe(_accum.dy > 0 ? Dir2048.down : Dir2048.up);
    }
  }

  static const _colors = {
    2: Color(0xFFEEE4DA), 4: Color(0xFFEDE0C8), 8: Color(0xFFF2B179), 16: Color(0xFFF59563),
    32: Color(0xFFF67C5F), 64: Color(0xFFF65E3B), 128: Color(0xFFEDCF72), 256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850), 1024: Color(0xFFEDC53F), 2048: Color(0xFFEDC22E),
  };

  Widget _tile(int v, double cell) {
    final dark = v <= 4;
    final digits = '$v'.length;
    final fs = cell * (digits <= 2 ? 0.42 : (digits == 3 ? 0.34 : 0.26));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: Tween(begin: 0.6, end: 1.0).animate(anim), child: child),
      child: Container(
        key: ValueKey('t-$v-${v == 0 ? 0 : 1}'),
        decoration: BoxDecoration(
          color: v == 0 ? Colors.black.withOpacity(0.07) : (_colors[v] ?? const Color(0xFF3C3A32)),
          borderRadius: BorderRadius.circular(cell * 0.12),
        ),
        alignment: Alignment.center,
        child: v == 0
            ? null
            : Text('$v',
                style: TextStyle(
                    fontSize: fs,
                    fontWeight: FontWeight.w900,
                    color: dark ? const Color(0xFF776E65) : Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.high(_key);
    return GameScaffold(
      title: l.game2048,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
      celebrate: _reached && !_over,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.gameScore(_game.score),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(best == null ? l.gameNoRecord : l.gameBestScore(best)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _over
              ? ResultBanner(
                  key: ValueKey('over-$_gen-${_game.score}'),
                  text: _newRecord ? '${l.gameOver} 🏆' : l.gameOver,
                  kind: _newRecord ? ResultKind.win : ResultKind.lose,
                )
              : _reached
                  ? ResultBanner(key: ValueKey('reached-$_gen'), text: '2048! 🎉', kind: ResultKind.win)
                  : Text(l.game2048Hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        LayoutBuilder(builder: (context, box) {
          final side = min(box.maxWidth, 420.0);
          const pad = 8.0, gap = 8.0;
          final cell = (side - 2 * pad - (_size - 1) * gap) / _size;
          return Center(
            child: Listener(
              onPointerDown: (_) => setState(() => _locked = true),
              onPointerUp: (_) => setState(() => _locked = false),
              onPointerCancel: (_) => setState(() => _locked = false),
              child: GestureDetector(
                onPanStart: (_) {
                  _swiped = false;
                  _accum = Offset.zero;
                },
                onPanUpdate: _pan,
                child: Container(
                  width: side,
                  height: side,
                  padding: const EdgeInsets.all(pad),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GridView.count(
                    crossAxisCount: _size,
                    mainAxisSpacing: gap,
                    crossAxisSpacing: gap,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [for (final v in _game.cells) _tile(v, cell)],
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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_common.dart';
import 'logic/game2048_logic.dart';
import '../services/game_sound.dart';

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
    _newGame(save: false);
    _restore();
  }

  // La partita in corso viene salvata: uscendo (anche per sbaglio) si riprende.
  String get _saveKey => 'game2048_state_$_size';

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parts = (prefs.getString(_saveKey) ?? '').split(';');
      if (parts.length != 2) return;
      final cells = parts[1].split(',').map(int.parse).toList();
      if (cells.length != _size * _size || !mounted) return;
      final g = Game2048.fromCells(_size, cells, _rand, score: int.parse(parts[0]));
      if (!g.canMove) return;
      setState(() {
        _game = g;
        _reached = g.maxTile >= 2048;
        _gen++;
      });
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_over) {
        await prefs.remove(_saveKey);
      } else {
        await prefs.setString(_saveKey, '${_game.score};${_game.cells.join(',')}');
      }
    } catch (_) {}
  }

  void _newGame({bool save = true}) {
    setState(() {
      _game = Game2048(_size, _rand);
      _reached = false;
      _over = false;
      _newRecord = false;
      _gen++;
    });
    if (save) _persist();
  }

  Future<void> _swipe(Dir2048 d) async {
    if (_over) return;
    final moved = _game.move(d);
    if (!moved) return;
    GameSound.instance.play(_game.mergedIds.isNotEmpty ? Sfx.pop : Sfx.step);
    setState(() {
      if (_game.maxTile >= 2048) _reached = true;
      _over = !_game.canMove;
    });
    _persist();
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

  static const _slide = Duration(milliseconds: 130);

  Widget _face(int v, double cell) {
    final dark = v <= 4;
    final digits = '$v'.length;
    final fs = cell * (digits <= 2 ? 0.42 : (digits == 3 ? 0.34 : 0.26));
    return Container(
      decoration: BoxDecoration(
        color: _colors[v] ?? const Color(0xFF3C3A32),
        borderRadius: BorderRadius.circular(cell * 0.12),
      ),
      alignment: Alignment.center,
      child: Text('$v',
          style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w900,
              color: dark ? const Color(0xFF776E65) : Colors.white)),
    );
  }

  /// Le tessere scivolano fino alla nuova casella; le due che si sommano
  /// arrivano insieme e al loro posto "scoppia" la tessera con il doppio.
  List<Widget> _tiles(double cell, double gap) {
    Widget at(int index, Key key, Widget child) => AnimatedPositioned(
          key: key,
          duration: _slide,
          curve: Curves.easeOut,
          left: (index % _size) * (cell + gap),
          top: (index ~/ _size) * (cell + gap),
          width: cell,
          height: cell,
          child: child,
        );
    return [
      for (var i = 0; i < _size * _size; i++)
        Positioned(
          left: (i % _size) * (cell + gap),
          top: (i ~/ _size) * (cell + gap),
          width: cell,
          height: cell,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.07),
              borderRadius: BorderRadius.circular(cell * 0.12),
            ),
          ),
        ),
      for (final g in _game.ghosts) at(g.to, ValueKey('$_gen-${g.id}'), _face(g.value, cell)),
      for (var i = 0; i < _size * _size; i++)
        if (_game.cells[i] != 0)
          at(
            i,
            ValueKey('$_gen-${_game.ids[i]}'),
            _game.mergedIds.contains(_game.ids[i])
                ? _Appear(merged: true, child: _face(_game.cells[i], cell))
                : _game.spawnedId == _game.ids[i]
                    ? _Appear(merged: false, child: _face(_game.cells[i], cell))
                    : _face(_game.cells[i], cell),
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.high(_key);
    return GameScaffold(
      title: l.game2048,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
      guardBack: true,
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
                  child: Stack(children: _tiles(cell, gap)),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        GameButton(onPressed: () => _newGame(), icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

/// Comparsa di una tessera dopo lo scorrimento: quella nata da una somma
/// "scoppia" (si ingrandisce e torna normale), quella nuova cresce da zero.
class _Appear extends StatelessWidget {
  final bool merged;
  final Widget child;
  const _Appear({required this.merged, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 330),
      child: child,
      builder: (context, t, child) {
        // Primo 40%: attesa che le tessere finiscano di scorrere.
        final p = ((t - 0.4) / 0.6).clamp(0.0, 1.0);
        if (t < 0.4) return const SizedBox.shrink();
        final scale = merged ? 1 + 0.22 * sin(p * pi) : Curves.easeOutBack.transform(p);
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

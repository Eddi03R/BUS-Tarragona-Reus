import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/watersort_logic.dart';
import '../services/game_sound.dart';

const _liquid = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFDD835),
  Color(0xFF8E24AA),
  Color(0xFFFB8C00),
  Color(0xFF00ACC1),
  Color(0xFFEC407A),
];

/// Travasa i colori: tocca una provetta e poi un'altra per versare; vinci
/// quando ogni provetta contiene un solo colore.
class WaterSortScreen extends StatefulWidget {
  final Difficulty difficulty;
  const WaterSortScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<WaterSortScreen> createState() => _WaterSortScreenState();
}

class _WaterSortScreenState extends State<WaterSortScreen> {
  final _rand = Random();
  late List<List<int>> _start;
  late List<List<int>> _tubes;
  final List<List<List<int>>> _undo = [];
  int? _sel;
  int _moves = 0;
  bool _won = false, _newRecord = false;

  int get _d => widget.difficulty.index;
  String get _key => 'watersort_${widget.difficulty.name}';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _load(List<List<int>> t) {
    setState(() {
      _start = t;
      _tubes = [for (final x in t) List<int>.of(x)];
      _undo.clear();
      _sel = null;
      _moves = 0;
      _won = _newRecord = false;
    });
  }

  void _newGame() => _load(WaterSortLogic.generate(_d, _rand));
  void _restart() => _load(_start);

  Future<void> _tap(int i) async {
    if (_won) return;
    final s = _sel;
    if (s == null) {
      if (_tubes[i].isNotEmpty) {
        GameSound.instance.play(Sfx.tap);
        setState(() => _sel = i);
      }
      return;
    }
    if (s == i) {
      setState(() => _sel = null);
      return;
    }
    if (!WaterSortLogic.canPour(_tubes, s, i)) {
      // se è un'altra provetta con qualcosa, la nuova selezione sostituisce la vecchia
      HapticFeedback.selectionClick();
      setState(() => _sel = _tubes[i].isNotEmpty ? i : null);
      return;
    }
    GameSound.instance.play(Sfx.place);
    _undo.add([for (final x in _tubes) List<int>.of(x)]);
    final next = WaterSortLogic.pour(_tubes, s, i);
    final win = WaterSortLogic.isSolved(next);
    var record = false;
    if (win) record = await GameStats.instance.submitBest(_key, _moves + 1);
    if (!mounted) return;
    setState(() {
      _tubes = next;
      _sel = null;
      _moves++;
      if (win) {
        _won = true;
        _newRecord = record;
      }
    });
  }

  void _undoMove() {
    if (_undo.isEmpty || _won) return;
    setState(() {
      _tubes = _undo.removeLast();
      _sel = null;
      _moves = max(0, _moves - 1);
    });
  }

  Widget _tube(int i) {
    final scheme = Theme.of(context).colorScheme;
    final t = _tubes[i];
    final selected = _sel == i;
    return GestureDetector(
      onTap: () => _tap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.translationValues(0, selected ? -12 : 0, 0),
        width: 52,
        height: WaterSortLogic.cap * 34.0 + 20,
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(26)),
          border: Border.all(color: selected ? scheme.primary : scheme.outline, width: selected ? 3 : 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (final c in t.reversed)
              Container(
                height: 32,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(color: _liquid[c], borderRadius: BorderRadius.circular(8)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_key);
    return GameScaffold(
      title: l.gameWaterSort,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(l.gameMoves(_moves),
                  overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(best == null ? l.gameNoRecord : l.gameBestMoves(best)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: const ValueKey('ww'),
                  text: _newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin,
                  kind: ResultKind.win)
              : Text(l.gameWaterSortHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 22,
          children: [for (var i = 0; i < _tubes.length; i++) _tube(i)],
        ),
        const SizedBox(height: 26),
        if (!_won) ...[
          GameButton(
            primary: false,
            onPressed: _undo.isEmpty ? null : _undoMove,
            icon: Icons.undo_rounded,
            label: l.wsUndo,
          ),
          const SizedBox(height: 10),
          GameButton(primary: false, onPressed: _restart, icon: Icons.replay_rounded, label: l.wsRestart),
          const SizedBox(height: 10),
        ],
        GameButton(primary: _won, onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

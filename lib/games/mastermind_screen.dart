import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/mastermind_logic.dart';
import '../services/game_sound.dart';

const _pegColors = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFDD835),
  Color(0xFF8E24AA),
  Color(0xFFFB8C00),
  Color(0xFF00ACC1),
];

/// Mastermind: indovina il codice di colori; ogni tentativo dà due indizi
/// (nero = colore e posto giusti, bianco = colore giusto al posto sbagliato).
class MastermindScreen extends StatefulWidget {
  final Difficulty difficulty;
  const MastermindScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<MastermindScreen> createState() => _MastermindScreenState();
}

class _MastermindScreenState extends State<MastermindScreen> {
  final _rand = Random();
  late List<int> _code;
  final List<List<int>> _guesses = [];
  final List<(int, int)> _feedback = [];
  late List<int> _cur; // tentativo in corso (-1 = posto vuoto)
  bool _won = false, _lost = false, _newRecord = false;

  int get _d => widget.difficulty.index;
  int get _pegs => MastermindLogic.pegs(_d);
  int get _max => MastermindLogic.attempts(_d);
  String get _key => 'mastermind_${widget.difficulty.name}';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _code = MastermindLogic.newCode(_d, _rand);
      _guesses.clear();
      _feedback.clear();
      _cur = List.filled(_pegs, -1);
      _won = _lost = _newRecord = false;
    });
  }

  void _pick(int color) {
    if (_won || _lost) return;
    final i = _cur.indexOf(-1);
    if (i < 0) return;
    GameSound.instance.play(Sfx.tap);
    setState(() => _cur[i] = color);
  }

  void _clear(int slot) {
    if (_won || _lost || _cur[slot] < 0) return;
    setState(() => _cur[slot] = -1);
  }

  Future<void> _check() async {
    if (_cur.contains(-1) || _won || _lost) return;
    final g = List<int>.of(_cur);
    final fb = MastermindLogic.score(_code, g);
    HapticFeedback.selectionClick();
    final win = fb.$1 == _pegs;
    var record = false;
    if (win) record = await GameStats.instance.submitBest(_key, _guesses.length + 1);
    if (!mounted) return;
    GameSound.instance.play(win ? Sfx.correct : Sfx.place);
    setState(() {
      _guesses.add(g);
      _feedback.add(fb);
      _cur = List.filled(_pegs, -1);
      if (win) {
        _won = true;
        _newRecord = record;
      } else if (_guesses.length >= _max) {
        _lost = true;
      }
    });
  }

  Widget _peg(Color? c, {double size = 34, VoidCallback? onTap}) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c ?? scheme.surfaceContainerHighest,
          border: Border.all(color: c == null ? scheme.outlineVariant : Colors.black26, width: 1.5),
        ),
      ),
    );
  }

  Widget _fb((int, int)? f) {
    final scheme = Theme.of(context).colorScheme;
    final dots = <Color?>[
      if (f != null) ...List.filled(f.$1, Colors.black),
      if (f != null) ...List.filled(f.$2, Colors.white),
    ];
    final cols = _pegs <= 4 ? 2 : 3;
    return SizedBox(
      width: cols * 14.0,
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: [
          for (var i = 0; i < _pegs; i++)
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < dots.length ? dots[i] : Colors.transparent,
                border: Border.all(color: scheme.outline.withOpacity(i < dots.length ? 0.9 : 0.3)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_key);
    final over = _won || _lost;
    return GameScaffold(
      title: l.gameMastermind,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(l.mmAttemptsLeft(_max - _guesses.length),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(best == null ? l.gameNoRecord : l.mmBestAttempts(best)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: const ValueKey('mw'),
                  text: _newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin,
                  kind: ResultKind.win)
              : _lost
                  ? ResultBanner(key: const ValueKey('ml'), text: l.gameYouLose, kind: ResultKind.lose)
                  : Text(l.mmLegend,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        // tentativi: fatti, in corso, da fare
        for (var r = 0; r < _max; r++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 22, child: Text('${r + 1}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant))),
                for (var i = 0; i < _pegs; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: r < _guesses.length
                        ? _peg(_pegColors[_guesses[r][i]])
                        : r == _guesses.length && !over
                            ? _peg(_cur[i] < 0 ? null : _pegColors[_cur[i]], onTap: () => _clear(i))
                            : Opacity(opacity: 0.4, child: _peg(null)),
                  ),
                const SizedBox(width: 10),
                _fb(r < _guesses.length ? _feedback[r] : null),
              ],
            ),
          ),
        if (_lost) ...[
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${l.mmTheCode}  '),
            for (final c in _code)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: _peg(_pegColors[c], size: 26)),
          ]),
        ],
        const SizedBox(height: 14),
        if (!over) ...[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var c = 0; c < MastermindLogic.colors(_d); c++) _peg(_pegColors[c], size: 42, onTap: () => _pick(c)),
            ],
          ),
          const SizedBox(height: 14),
          GameButton(
            onPressed: _cur.contains(-1) ? null : _check,
            icon: Icons.check_rounded,
            label: l.mmCheck,
          ),
          const SizedBox(height: 10),
        ],
        GameButton(
            primary: over, onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

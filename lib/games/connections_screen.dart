import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import 'logic/connections_data.dart';
import '../services/game_sound.dart';

/// Connessioni: raggruppa le 16 parole in 4 gruppi da 4. Quattro errori e hai perso.
class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  static const _colors = [
    Color(0xFFF9A825),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
  ];
  static const int maxMistakes = 4;
  final _rand = Random();
  static int _lastPuzzle = -1;
  late int _puzzle;
  late List<String> _board; // parole ancora in gioco
  final List<int> _solved = []; // indici dei gruppi trovati, in ordine
  final Set<String> _selected = {};
  final Set<String> _wrong = {}; // parole sbagliate dell'ultimo tentativo (in rosso per un attimo)
  Timer? _wrongTimer;
  late List<int> _catOrder; // ordine (mescolato) con cui si mostrano le categorie
  int _mistakes = 0;
  bool _won = false;
  bool _lost = false;
  bool _oneAway = false;

  ConnPuzzle get _p => connPuzzles[_puzzle];

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _wrongTimer?.cancel();
    super.dispose();
  }

  void _newGame() {
    _wrongTimer?.cancel();
    var next = _rand.nextInt(connPuzzles.length);
    if (connPuzzles.length > 1 && next == _lastPuzzle) next = (next + 1) % connPuzzles.length;
    _lastPuzzle = next;
    setState(() {
      _puzzle = next;
      _board = [for (final g in _p.groups) ...g.words]..shuffle(_rand);
      _solved.clear();
      _selected.clear();
      _wrong.clear();
      _catOrder = List.generate(_p.groups.length, (i) => i)..shuffle(_rand);
      _mistakes = 0;
      _won = false;
      _lost = false;
      _oneAway = false;
    });
  }

  void _toggle(String w) {
    if (_won || _lost) return;
    GameSound.instance.play(Sfx.tap);
    _wrongTimer?.cancel();
    setState(() {
      _wrong.clear();
      _oneAway = false;
      if (_selected.contains(w)) {
        _selected.remove(w);
      } else if (_selected.length < 4) {
        _selected.add(w);
      }
    });
  }

  Future<void> _submit() async {
    if (_selected.length != 4 || _won || _lost) return;
    final gi = [
      for (var i = 0; i < _p.groups.length; i++)
        if (!_solved.contains(i)) i
    ];
    var bestMatch = 0;
    var bestGroup = -1;
    for (final i in gi) {
      final hit = _p.groups[i].words.where(_selected.contains).length;
      if (hit == 4) {
        HapticFeedback.mediumImpact();
        GameSound.instance.play(Sfx.correct);
        setState(() {
          _solved.add(i);
          _board.removeWhere(_selected.contains);
          _selected.clear();
          _oneAway = false;
        });
        if (_solved.length == _p.groups.length) {
          await GameStats.instance.setValue(
              'connections_solved', GameStats.instance.value('connections_solved') + 1);
          if (mounted) setState(() => _won = true);
        }
        return;
      }
      if (hit > bestMatch) {
        bestMatch = hit;
        bestGroup = i;
      }
    }
    HapticFeedback.heavyImpact();
    GameSound.instance.play(Sfx.wrong);
    // in rosso le parole che non stanno nel gruppo più vicino (tutte e 4 se nessuna ci sta)
    final wrong = bestGroup < 0
        ? _selected.toSet()
        : _selected.where((w) => !_p.groups[bestGroup].words.contains(w)).toSet();
    _wrongTimer?.cancel();
    _wrongTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(_wrong.clear);
    });
    setState(() {
      _mistakes++;
      _oneAway = bestMatch == 3;
      _wrong..clear()..addAll(wrong);
      _selected.clear();
      if (_mistakes >= maxMistakes) {
        _lost = true;
        for (var i = 0; i < _p.groups.length; i++) {
          if (!_solved.contains(i)) _solved.add(i);
        }
        _board.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final done = GameStats.instance.value('connections_solved');
    return GameScaffold(
      title: l.gameConnections,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text('${l.connMistakes} ', style: const TextStyle(fontWeight: FontWeight.w600)),
              for (var i = 0; i < maxMistakes; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Icon(Icons.circle,
                      size: 14,
                      color: i < maxMistakes - _mistakes ? scheme.primary : scheme.outlineVariant),
                ),
            ]),
            Text(l.connSolvedCount(done)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(key: const ValueKey('cw'), text: l.gameYouWin, kind: ResultKind.win)
              : _lost
                  ? ResultBanner(key: const ValueKey('cl'), text: l.gameYouLose, kind: ResultKind.lose)
                  : Text(_oneAway ? l.connOneAway : l.gameConnectionsHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: _oneAway ? FontWeight.w700 : FontWeight.w400,
                          color: _oneAway ? scheme.primary : scheme.onSurfaceVariant)),
        ),
        // gruppi già trovati
        for (final i in _solved)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: _colors[i], borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Text(_p.groups[i].titleFor(lang).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 2),
                Text(_p.groups[i].words.join(' · '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        // categorie ancora da trovare (nomi dei gruppi, in ordine casuale)
        if (!_won && !_lost)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final i in _catOrder)
                  if (!_solved.contains(i))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.outlineVariant),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_p.groups[i].titleFor(lang),
                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    ),
              ],
            ),
          ),
        if (_board.isNotEmpty)
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.25,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final w in _board)
                GestureDetector(
                  onTap: () => _toggle(w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _wrong.contains(w)
                          ? Colors.red.shade600
                          : _selected.contains(w)
                              ? scheme.primary
                              : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(w,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _wrong.contains(w)
                              ? Colors.white
                              : _selected.contains(w)
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                        )),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
        if (!_won && !_lost) ...[
          GameButton(
            onPressed: _selected.length == 4 ? _submit : null,
            icon: Icons.check_rounded,
            label: l.connSubmit,
          ),
          const SizedBox(height: 10),
          HintButton(
            game: 'connections',
            onGranted: () => setState(() {
              // seleziona una parola di un gruppo ancora da trovare
              final open = [
                for (var i = 0; i < _p.groups.length; i++)
                  if (!_solved.contains(i)) i
              ];
              if (open.isEmpty) return;
              final words = _p.groups[open[_rand.nextInt(open.length)]].words.where(_board.contains).toList();
              _selected
                ..clear()
                ..add(words[_rand.nextInt(words.length)]);
              _wrong.clear();
              _oneAway = false;
            }),
          ),
          GameButton(
            primary: false,
            onPressed: () => setState(() {
              _board.shuffle(_rand);
              _selected.clear();
              _wrong.clear();
            }),
            icon: Icons.shuffle_rounded,
            label: l.connShuffle,
          ),
        ] else
          GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

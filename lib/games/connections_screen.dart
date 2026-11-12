import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/connections_data.dart';

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

  void _newGame() {
    var next = _rand.nextInt(connPuzzles.length);
    if (connPuzzles.length > 1 && next == _lastPuzzle) next = (next + 1) % connPuzzles.length;
    _lastPuzzle = next;
    setState(() {
      _puzzle = next;
      _board = [for (final g in _p.groups) ...g.words]..shuffle(_rand);
      _solved.clear();
      _selected.clear();
      _mistakes = 0;
      _won = false;
      _lost = false;
      _oneAway = false;
    });
  }

  void _toggle(String w) {
    if (_won || _lost) return;
    setState(() {
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
    for (final i in gi) {
      final hit = _p.groups[i].words.where(_selected.contains).length;
      if (hit == 4) {
        HapticFeedback.mediumImpact();
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
      bestMatch = max(bestMatch, hit);
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _mistakes++;
      _oneAway = bestMatch == 3;
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
                      color: _selected.contains(w) ? scheme.primary : scheme.surfaceContainerHighest,
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
                          color: _selected.contains(w) ? scheme.onPrimary : scheme.onSurface,
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
          GameButton(
            primary: false,
            onPressed: () => setState(() {
              _board.shuffle(_rand);
              _selected.clear();
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

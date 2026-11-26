import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import 'logic/slide_logic.dart';
import '../services/game_sound.dart';

/// Puzzle scorrevole. Facile 3×3, medio 4×4, difficile 5×5.
class SlideScreen extends StatefulWidget {
  final Difficulty difficulty;
  const SlideScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<SlideScreen> createState() => _SlideScreenState();
}

class _SlideScreenState extends State<SlideScreen> {
  final _rand = Random();
  final _watch = Stopwatch();
  Timer? _ticker;
  late List<int> _tiles;
  int _moves = 0;
  bool _won = false;
  bool _newRecord = false;
  int? _hintTile; // tessera consigliata (aiuto con pubblicità)

  int get _n => 3 + widget.difficulty.index;
  String get _key => 'slide_${widget.difficulty.name}';

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
      _tiles = SlideLogic.shuffled(_n, _rand);
      _moves = 0;
      _won = false;
      _newRecord = false;
      _hintTile = null;
    });
  }

  Future<void> _tap(int i) async {
    if (_won) return;
    final moved = SlideLogic.slide(_tiles, _n, i);
    if (moved == 0) return;
    HapticFeedback.selectionClick();
    GameSound.instance.play(Sfx.place);
    if (!_watch.isRunning) {
      _watch.start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() {
      _moves++;
      _hintTile = null;
    });
    if (SlideLogic.isSolved(_tiles)) {
      _watch.stop();
      _ticker?.cancel();
      final record = await GameStats.instance.submitBest(_key, _moves);
      if (!mounted) return;
      setState(() {
        _won = true;
        _newRecord = record;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_key);
    return GameScaffold(
      title: l.gameSlide,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtTime(_watch.elapsedMilliseconds),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(l.gameMoves(_moves)),
            Text(best == null ? l.gameNoRecord : l.gameBestMoves(best)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: ValueKey('won-$_moves'),
                  text: _newRecord ? '${l.gameSolved} 🏆' : l.gameSolved,
                  kind: ResultKind.win,
                )
              : Text(l.gameSlideHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(builder: (context, box) {
            final side = box.maxWidth;
            final cell = side / _n;
            return Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  for (var i = 0; i < _tiles.length; i++)
                    if (_tiles[i] != 0)
                      AnimatedPositioned(
                        key: ValueKey(_tiles[i]),
                        duration: const Duration(milliseconds: 130),
                        curve: Curves.easeOut,
                        left: (i % _n) * cell,
                        top: (i ~/ _n) * cell,
                        width: cell,
                        height: cell,
                        child: GestureDetector(
                          onTap: () => _tap(i),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _tiles[i] == i + 1
                                    ? Colors.green.shade600
                                    : scheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                border: _tiles[i] == _hintTile ? Border.all(color: Colors.amber, width: 4) : null,
                              ),
                              alignment: Alignment.center,
                              child: Text('${_tiles[i]}',
                                  style: TextStyle(
                                      fontSize: cell * 0.42,
                                      fontWeight: FontWeight.w900,
                                      color: _tiles[i] == i + 1 ? Colors.white : scheme.onPrimary)),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        if (!_won) HintButton(game: 'slide', onGranted: _hint),
        GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }

  /// Aiuto con pubblicità: evidenzia la tessera vicina al vuoto che si avvicina di più al suo posto.
  /// shortcut: scelta golosa (non il percorso più breve), può non convergere da sola; per un solutore vero serve IDA*.
  void _hint() {
    final n = _n, blank = _tiles.indexOf(0);
    int dist(int from, int to) => (from % n - to % n).abs() + (from ~/ n - to ~/ n).abs();
    final near = [
      if (blank % n > 0) blank - 1,
      if (blank % n < n - 1) blank + 1,
      if (blank >= n) blank - n,
      if (blank < n * (n - 1)) blank + n,
    ]..shuffle(_rand);
    var best = near.first, bestGain = -99;
    for (final j in near) {
      final target = _tiles[j] - 1;
      final gain = dist(j, target) - dist(blank, target);
      if (gain > bestGain) {
        bestGain = gain;
        best = j;
      }
    }
    setState(() => _hintTile = _tiles[best]);
  }
}

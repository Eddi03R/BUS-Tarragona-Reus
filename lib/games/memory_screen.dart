import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/memory_logic.dart';

const _symbols = [
  '🚌', '🚏', '🎟️', '🏖️', '🌴', '⚓', '🎓', '🌙', '☀️', '🎉', '🍕', '🚲', '🗺️', '🎵', '🚆', '🥐',
];

/// Memory: trova tutte le coppie. Difficoltà = numero di carte.
class MemoryScreen extends StatefulWidget {
  final Difficulty difficulty;
  const MemoryScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _rand = Random();
  final _watch = Stopwatch();
  Timer? _ticker;
  late List<int> _deck;
  late List<bool> _matched;
  final List<int> _open = [];
  bool _busy = false;
  int _moves = 0;
  bool _won = false;
  bool _newRecord = false;

  int get _d => widget.difficulty.index;
  String get _key => 'memory_${widget.difficulty.name}';

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
      _deck = MemoryLogic.deal(MemoryLogic.pairsFor(_d), _rand);
      _matched = List.filled(_deck.length, false);
      _open.clear();
      _busy = false;
      _moves = 0;
      _won = false;
      _newRecord = false;
    });
  }

  Future<void> _tap(int i) async {
    if (_busy || _won || _matched[i] || _open.contains(i)) return;
    if (!_watch.isRunning) {
      _watch.start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() => _open.add(i));
    if (_open.length < 2) return;
    _moves++;
    final a = _open[0], b = _open[1];
    if (_deck[a] == _deck[b]) {
      setState(() {
        _matched[a] = true;
        _matched[b] = true;
        _open.clear();
      });
      if (_matched.every((m) => m)) {
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
    } else {
      _busy = true;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _open.clear();
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cols = MemoryLogic.columnsFor(_d);
    final best = GameStats.instance.best(_key);
    return GameScaffold(
      title: l.gameMemory,
      celebrate: _won,
      children: [
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
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: ValueKey('won-$_moves'),
                  text: _newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin,
                  kind: ResultKind.win,
                )
              : Text(l.gameMemoryHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < _deck.length; i++)
              _MemoryCard(
                symbol: _symbols[_deck[i] % _symbols.length],
                faceUp: _open.contains(i) || _matched[i],
                matched: _matched[i],
                onTap: () => _tap(i),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final String symbol;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;
  const _MemoryCard(
      {required this.symbol, required this.faceUp, required this.matched, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: faceUp ? 1 : 0),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
        builder: (context, t, _) {
          final showFront = t > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(t * pi),
            child: Container(
              decoration: BoxDecoration(
                color: showFront
                    ? (matched ? Colors.green.shade100 : Colors.white)
                    : scheme.primary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: matched ? Colors.green.shade400 : scheme.primary.withOpacity(0.35), width: 2),
              ),
              alignment: Alignment.center,
              child: showFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: Text(symbol, style: const TextStyle(fontSize: 32)),
                    )
                  : Icon(Icons.question_mark_rounded, color: scheme.onPrimary, size: 30),
            ),
          );
        },
      ),
    );
  }
}

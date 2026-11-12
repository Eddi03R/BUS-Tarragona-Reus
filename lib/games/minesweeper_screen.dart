import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/minesweeper_logic.dart';

/// Campo minato. Tocco = scopri, tocco lungo (o modalità bandiera) = bandiera.
class MinesweeperScreen extends StatefulWidget {
  final Difficulty difficulty;
  const MinesweeperScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreenState();
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  final _rand = Random();
  final _watch = Stopwatch();
  Timer? _ticker;
  late MinesBoard _b;
  bool _flagMode = false;
  bool _done = false;
  bool _newRecord = false;

  String get _key => 'mines_${widget.difficulty.name}';

  static const _numColors = [
    Colors.transparent,
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFD32F2F),
    Color(0xFF7B1FA2),
    Color(0xFFFF8F00),
    Color(0xFF00838F),
    Color(0xFF424242),
    Color(0xFF757575),
  ];

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
      _b = MinesBoard.forDifficulty(widget.difficulty.index);
      _done = false;
      _newRecord = false;
      _flagMode = false;
    });
  }

  Future<void> _tap(int i) async {
    if (_done) return;
    if (_flagMode) {
      setState(() => _b.toggleFlag(i));
      return;
    }
    if (!_watch.isRunning) {
      _watch.start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() => _b.reveal(i, _rand));
    await _checkEnd();
  }

  void _long(int i) {
    if (_done) return;
    HapticFeedback.selectionClick();
    setState(() => _b.toggleFlag(i));
  }

  Future<void> _checkEnd() async {
    if (_b.lost) {
      _watch.stop();
      _ticker?.cancel();
      HapticFeedback.heavyImpact();
      setState(() => _done = true);
    } else if (_b.won) {
      _watch.stop();
      _ticker?.cancel();
      final record = await GameStats.instance.submitBest(_key, _watch.elapsedMilliseconds);
      if (!mounted) return;
      setState(() {
        _done = true;
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
      title: l.gameMines,
      celebrate: _done && !_b.lost,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtTime(_watch.elapsedMilliseconds),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('🚩 ${_b.flagsLeft}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(best == null ? l.gameNoRecord : l.gameBest(fmtTime(best))),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _done
              ? ResultBanner(
                  key: ValueKey('end-${_b.lost}'),
                  text: _b.lost ? l.gameYouLose : (_newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin),
                  kind: _b.lost ? ResultKind.lose : ResultKind.win,
                )
              : Text(l.gameMinesHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        AspectRatio(
          aspectRatio: _b.cols / _b.rows,
          child: Column(
            children: [
              for (var r = 0; r < _b.rows; r++)
                Expanded(
                  child: Row(
                    children: [
                      for (var c = 0; c < _b.cols; c++) Expanded(child: _cell(_b.idx(r, c), scheme)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, icon: const Icon(Icons.touch_app_rounded), label: Text(l.gameMinesDig)),
            ButtonSegment(value: true, icon: const Icon(Icons.flag_rounded), label: Text(l.gameMinesFlag)),
          ],
          selected: {_flagMode},
          onSelectionChanged: (v) => setState(() => _flagMode = v.first),
        ),
        const SizedBox(height: 12),
        GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }

  Widget _cell(int i, ColorScheme scheme) {
    final open = _b.open[i];
    final mine = _b.mine[i];
    final exploded = _b.explodedAt == i;
    Widget? child;
    Color bg = scheme.primary.withOpacity(0.85);
    if (open) {
      bg = exploded ? Colors.red.shade400 : scheme.surfaceContainerHighest;
      if (mine) {
        child = const Text('💣', style: TextStyle(fontSize: 16));
      } else if (_b.near[i] > 0) {
        child = Text('${_b.near[i]}',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 17, color: _numColors[_b.near[i]]));
      }
    } else if (_b.flag[i]) {
      child = const Text('🚩', style: TextStyle(fontSize: 15));
    }
    return GestureDetector(
      onTap: () => _tap(i),
      onLongPress: () => _long(i),
      child: Container(
        margin: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

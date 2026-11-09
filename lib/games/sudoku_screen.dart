import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/sudoku_logic.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final _rand = Random();
  final _watch = Stopwatch();
  Timer? _ticker;
  Difficulty _difficulty = Difficulty.easy;
  List<int> _grid = List.filled(81, 0);
  List<bool> _given = List.filled(81, false);
  Set<int> _bad = {};
  int _selected = -1;
  bool _loading = true;
  bool _won = false;
  bool _newRecord = false;

  String get _bestKey => 'sudoku_${_difficulty.name}';

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

  Future<void> _newGame() async {
    _ticker?.cancel();
    _watch
      ..stop()
      ..reset();
    setState(() {
      _loading = true;
      _won = false;
      _newRecord = false;
      _selected = -1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 60)); // lascia ridisegnare
    final p = SudokuLogic.generate(_difficulty.index, _rand);
    if (!mounted) return;
    setState(() {
      _grid = List<int>.from(p.puzzle);
      _given = [for (final v in p.puzzle) v != 0];
      _bad = {};
      _loading = false;
    });
    _watch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _put(int digit) async {
    if (_selected < 0 || _given[_selected] || _won || _loading) return;
    setState(() {
      _grid[_selected] = digit;
      _bad = SudokuLogic.conflicts(_grid);
    });
    if (!_grid.contains(0) && _bad.isEmpty) {
      _watch.stop();
      _ticker?.cancel();
      final record = await GameStats.instance.submitBest(_bestKey, _watch.elapsedMilliseconds);
      if (mounted) {
        setState(() {
          _won = true;
          _newRecord = record;
        });
      }
    }
  }

  Widget _cell(int i, ColorScheme scheme) {
    final r = i ~/ 9, c = i % 9;
    final v = _grid[i];
    final selected = i == _selected;
    final bad = _bad.contains(i);
    BorderSide side(bool thick) =>
        BorderSide(width: thick ? 2 : 0.5, color: scheme.onSurface.withOpacity(thick ? 0.8 : 0.25));
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selected = i),
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer
                : (_given[i] ? scheme.surfaceContainerHighest : Colors.transparent),
            border: Border(
              top: side(r % 3 == 0),
              left: side(c % 3 == 0),
              bottom: side(r == 8),
              right: side(c == 8),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            v == 0 ? '' : '$v',
            style: TextStyle(
              fontSize: 20,
              fontWeight: _given[i] ? FontWeight.w800 : FontWeight.w500,
              color: bad ? Colors.red : (_given[i] ? scheme.onSurface : scheme.primary),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_bestKey);
    return GameScaffold(
      title: l.gameSudoku,
      celebrate: _won,
      children: [
        DifficultyChips(value: _difficulty, onChanged: (d) {
          _difficulty = d;
          _newGame();
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtTime(_watch.elapsedMilliseconds),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(best == null ? l.gameNoRecord : l.gameBest(fmtTime(best))),
          ],
        ),
        const SizedBox(height: 8),
        if (_won)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ResultBanner(
              key: ValueKey('won-${_watch.elapsedMilliseconds}'),
              text: _newRecord ? '${l.gameSolved} 🏆' : l.gameSolved,
              kind: ResultKind.win,
            ),
          ),
        AspectRatio(
          aspectRatio: 1,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    for (var r = 0; r < 9; r++)
                      Expanded(
                        child: Row(children: [for (var c = 0; c < 9; c++) _cell(r * 9 + c, scheme)]),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var d = 1; d <= 9; d++)
              SizedBox(
                width: 52,
                height: 48,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => _put(d),
                  child: Text('$d', style: const TextStyle(fontSize: 20)),
                ),
              ),
            SizedBox(
              height: 48,
              child: OutlinedButton(onPressed: () => _put(0), child: Text(l.gameClear)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/busjam_logic.dart';

class BusJamScreen extends StatefulWidget {
  const BusJamScreen({super.key});

  @override
  State<BusJamScreen> createState() => _BusJamScreenState();
}

class _BusJamScreenState extends State<BusJamScreen> {
  int _level = 1;
  JamLevel? _jam;
  List<int> _pos = [];
  int _moves = 0;
  bool _won = false;
  bool _loading = true;

  int _dragStart = 0;
  int _lo = 0, _hi = 0;
  double _dragAccum = 0;

  int get _unlocked => GameStats.instance.value('busjam_unlocked', 1);

  static const _palette = [
    Colors.indigo, Colors.teal, Colors.orange, Colors.purple, Colors.brown,
    Colors.blueGrey, Colors.green, Colors.pink, Colors.cyan, Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _level = min(_unlocked, JamLogic.maxLevel);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final jam = JamLogic.generate(_level);
    if (!mounted) return;
    setState(() {
      _jam = jam;
      _pos = List<int>.from(jam.start);
      _moves = 0;
      _won = false;
      _loading = false;
    });
  }

  void _go(int level) {
    _level = level.clamp(1, min(_unlocked, JamLogic.maxLevel));
    _load();
  }

  void _dragBegin(int i) {
    final jam = _jam!;
    final occ = JamLogic.occupancy(jam.vehicles, _pos);
    final (lo, hi) = JamLogic.reach(jam.vehicles, _pos, i, occ);
    _lo = lo;
    _hi = hi;
    _dragStart = _pos[i];
    _dragAccum = 0;
  }

  void _dragUpdate(int i, DragUpdateDetails d, double cell) {
    if (_won) return;
    final horizontal = _jam!.vehicles[i].horizontal;
    _dragAccum += horizontal ? d.delta.dx : d.delta.dy;
    final target = (_dragStart + (_dragAccum / cell).round()).clamp(_lo, _hi);
    if (target != _pos[i]) setState(() => _pos[i] = target);
  }

  Future<void> _dragEnd(int i) async {
    if (_pos[i] == _dragStart) return;
    setState(() => _moves++);
    if (JamLogic.solved(_jam!.vehicles, _pos)) {
      await GameStats.instance.submitBest('busjam_$_level', _moves);
      if (_level + 1 > _unlocked && _level < JamLogic.maxLevel) {
        await GameStats.instance.setValue('busjam_unlocked', _level + 1);
      }
      if (mounted) setState(() => _won = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final jam = _jam;
    final best = GameStats.instance.best('busjam_$_level');
    return GameScaffold(
      title: l.gameBusJam,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _level > 1 ? () => _go(_level - 1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Text(l.gameLevel(_level),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            IconButton(
              onPressed: _level < min(_unlocked, JamLogic.maxLevel) ? () => _go(_level + 1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.gameMoves(_moves)),
            Text(best == null ? l.gameNoRecord : l.gameBestMoves(best)),
          ],
        ),
        const SizedBox(height: 8),
        if (_won)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l.gameLevelDone,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary)),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l.gameBusJamHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
        LayoutBuilder(builder: (context, box) {
          final side = min(box.maxWidth, 420.0);
          final cell = side / JamLogic.size;
          return Center(
            child: SizedBox(
              width: side,
              height: side,
              child: _loading || jam == null
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        // freccia di uscita
                        Positioned(
                          right: 2,
                          top: JamLogic.exitRow * cell + cell * 0.25,
                          child: Icon(Icons.keyboard_double_arrow_right_rounded,
                              color: Colors.red.shade400, size: cell * 0.5),
                        ),
                        for (var i = 0; i < jam.vehicles.length; i++)
                          _vehicle(i, jam.vehicles[i], cell),
                      ],
                    ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.gameRestart),
              ),
            ),
            if (_won && _level < JamLogic.maxLevel) ...[
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _go(_level + 1),
                  icon: const Icon(Icons.skip_next_rounded),
                  label: Text(l.gameNextLevel),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _vehicle(int i, JamVehicle v, double cell) {
    final x = v.horizontal ? _pos[i] : v.fixed;
    final y = v.horizontal ? v.fixed : _pos[i];
    final color = i == 0 ? Colors.red.shade600 : _palette[i % _palette.length];
    return Positioned(
      left: x * cell,
      top: y * cell,
      width: v.horizontal ? v.len * cell : cell,
      height: v.horizontal ? cell : v.len * cell,
      child: GestureDetector(
        onPanStart: (_) => _dragBegin(i),
        onPanUpdate: (d) => _dragUpdate(i, d, cell),
        onPanEnd: (_) => _dragEnd(i),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(v.len == 3 ? 12 : 16),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.directions_bus_rounded, color: Colors.white, size: min(cell * 0.5, 28)),
        ),
      ),
    );
  }
}

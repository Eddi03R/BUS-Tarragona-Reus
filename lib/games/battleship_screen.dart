import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/battleship_logic.dart';

enum _Phase { placing, playing }

class BattleshipScreen extends StatefulWidget {
  const BattleshipScreen({super.key});

  @override
  State<BattleshipScreen> createState() => _BattleshipScreenState();
}

class _BattleshipScreenState extends State<BattleshipScreen> {
  final _rand = Random();
  late BattleshipBoard _enemy;
  late BattleshipBoard _mine;
  _Phase _phase = _Phase.placing;
  bool _horizontal = true;
  bool _busy = false; // turno dell'avversario
  bool? _won; // null = in corso
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _enemy = BattleshipBoard.random(_rand);
    _mine = BattleshipBoard();
    _phase = _Phase.placing;
    _horizontal = true;
    _busy = false;
    _won = null;
    _msg = '';
  }

  int? get _nextShip {
    for (var id = 0; id < BattleshipBoard.shipLengths.length; id++) {
      if (!_mine.isPlaced(id)) return id;
    }
    return null;
  }

  // ------------------------------------------------------------- posizionamento
  void _placeAt(int idx) {
    final l = AppLocalizations.of(context)!;
    final x = idx % BattleshipBoard.size, y = idx ~/ BattleshipBoard.size;
    final existing = _mine.ship[idx];
    if (existing != -1) {
      setState(() => _mine.remove(existing)); // tocca una nave per rimuoverla
      return;
    }
    final next = _nextShip;
    if (next == null) return;
    if (!_mine.place(next, x, y, _horizontal)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(l.gameShipNoFit),
          duration: const Duration(milliseconds: 1200),
        ));
      return;
    }
    setState(() {});
  }

  void _randomize() => setState(() {
        _mine.clearShips();
        _mine.fillRandomly(_rand);
      });

  void _start() {
    if (!_mine.allPlaced) return;
    setState(() => _phase = _Phase.playing);
  }

  // ------------------------------------------------------------------- partita
  String _resultText(AppLocalizations l, BattleshipBoard b, int idx, bool hit) {
    if (!hit) return l.gameMiss;
    return b.isSunk(b.ship[idx]) ? l.gameSunk : l.gameHit;
  }

  Future<void> _fire(int idx) async {
    if (_phase != _Phase.playing || _busy || _won != null || _enemy.shot[idx]) return;
    final l = AppLocalizations.of(context)!;
    final hit = _enemy.fire(idx);
    setState(() {
      _msg = '${l.gameYou}: ${_resultText(l, _enemy, idx, hit)}';
      if (_enemy.allSunk) _won = true;
      _busy = _won == null;
    });
    if (_won != null) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final shot = BattleshipAi.nextShot(_mine, _rand);
    final h = _mine.fire(shot);
    setState(() {
      _msg = '$_msg   ·   ${l.gameOpponent}: ${_resultText(l, _mine, shot, h)}';
      if (_mine.allSunk) _won = false;
      _busy = false;
    });
  }

  // ------------------------------------------------------------------------ UI
  Widget _grid(BattleshipBoard b,
      {required bool enemy, required double cell, required void Function(int) onTap}) {
    return SizedBox(
      width: cell * BattleshipBoard.size,
      height: cell * BattleshipBoard.size,
      child: GridView.count(
        crossAxisCount: BattleshipBoard.size,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < BattleshipBoard.size * BattleshipBoard.size; i++)
            _cell(b, i, enemy, onTap),
        ],
      ),
    );
  }

  Widget _cell(BattleshipBoard b, int i, bool enemy, void Function(int) onTap) {
    final shot = b.shot[i];
    final isShip = b.ship[i] != -1;
    final sunk = isShip && b.isSunk(b.ship[i]);
    Color color;
    Widget? child;
    if (shot && isShip) {
      color = sunk ? Colors.red.shade900 : Colors.red.shade400;
      child = const Icon(Icons.close_rounded, color: Colors.white, size: 16);
    } else if (shot) {
      color = Colors.blueGrey.shade100;
      child = const Icon(Icons.circle, size: 6, color: Colors.blueGrey);
    } else if (!enemy && isShip) {
      color = Colors.blueGrey.shade600;
    } else {
      color = Colors.lightBlue.shade200;
    }
    return GestureDetector(
      onTap: () => onTap(i),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _banner(String text, Color bg, Color fg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: fg)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final big = min(width - 40, 420.0) / BattleshipBoard.size;
    final small = big * 0.55;

    if (_phase == _Phase.placing) {
      final next = _nextShip;
      return GameScaffold(
        title: l.gameBattleship,
        children: [
          Text(l.gamePlaceShips, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var id = 0; id < BattleshipBoard.shipLengths.length; id++)
                Chip(
                  avatar: Icon(
                    _mine.isPlaced(id) ? Icons.check_circle_rounded : Icons.directions_boat_rounded,
                    size: 18,
                    color: id == next ? scheme.primary : null,
                  ),
                  label: Text('${BattleshipBoard.shipLengths[id]}'),
                  backgroundColor: id == next ? scheme.primaryContainer : null,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Center(child: _grid(_mine, enemy: false, cell: big, onTap: _placeAt)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _horizontal = !_horizontal),
                  icon: Icon(_horizontal ? Icons.swap_horiz_rounded : Icons.swap_vert_rounded),
                  label: Text(_horizontal ? l.gameHorizontal : l.gameVertical),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _randomize,
                  icon: const Icon(Icons.casino_rounded),
                  label: Text(l.gameRandom),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _mine.allPlaced ? _start : null,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l.gameStart),
          ),
        ],
      );
    }

    final over = _won != null;
    final Widget status = over
        ? _banner(
            _won! ? l.gameYouWin : l.gameYouLose,
            _won! ? Colors.green.shade600 : Colors.red.shade600,
            Colors.white,
            _won! ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
          )
        : _busy
            ? _banner(l.gameEnemyTurn, Colors.orange.shade700, Colors.white, Icons.hourglass_top_rounded)
            : _banner(l.gameFire, Colors.green.shade600, Colors.white, Icons.gps_fixed_rounded);

    return GameScaffold(
      title: l.gameBattleship,
      children: [
        status,
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: Center(
            child: Text(_msg,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ),
        ),
        Text(l.gameEnemySea, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (_busy || over) ? 0.55 : 1,
            child: _grid(_enemy, enemy: true, cell: big, onTap: _fire),
          ),
        ),
        const SizedBox(height: 16),
        Text(l.gameYourSea, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Center(child: _grid(_mine, enemy: false, cell: small, onTap: (_) {})),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => setState(_reset),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l.gameNew),
        ),
      ],
    );
  }
}

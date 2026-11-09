import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/battleship_logic.dart';

class BattleshipScreen extends StatefulWidget {
  const BattleshipScreen({super.key});

  @override
  State<BattleshipScreen> createState() => _BattleshipScreenState();
}

class _BattleshipScreenState extends State<BattleshipScreen> {
  final _rand = Random();
  late BattleshipBoard _enemy;
  late BattleshipBoard _mine;
  bool _busy = false;
  bool? _won; // null = in corso
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _enemy = BattleshipBoard.random(_rand);
    _mine = BattleshipBoard.random(_rand);
    _busy = false;
    _won = null;
    _msg = '';
  }

  String _resultText(AppLocalizations l, BattleshipBoard b, int idx, bool hit) {
    if (!hit) return l.gameMiss;
    return b.isSunk(b.ship[idx]) ? l.gameSunk : l.gameHit;
  }

  Future<void> _fire(int idx) async {
    if (_busy || _won != null || _enemy.shot[idx]) return;
    final l = AppLocalizations.of(context)!;
    final hit = _enemy.fire(idx);
    setState(() {
      _msg = _resultText(l, _enemy, idx, hit);
      if (_enemy.allSunk) _won = true;
      _busy = _won == null;
    });
    if (_won != null) return;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final shot = BattleshipAi.nextShot(_mine, _rand);
    final h = _mine.fire(shot);
    setState(() {
      _msg = '$_msg · ${_resultText(l, _mine, shot, h)}';
      if (_mine.allSunk) _won = false;
      _busy = false;
    });
  }

  Widget _grid(BattleshipBoard b, {required bool enemy, required double cell}) {
    return SizedBox(
      width: cell * BattleshipBoard.size,
      height: cell * BattleshipBoard.size,
      child: GridView.count(
        crossAxisCount: BattleshipBoard.size,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < BattleshipBoard.size * BattleshipBoard.size; i++)
            _cell(b, i, enemy),
        ],
      ),
    );
  }

  Widget _cell(BattleshipBoard b, int i, bool enemy) {
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
      onTap: enemy ? () => _fire(i) : null,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final big = min(width - 40, 420.0) / BattleshipBoard.size;
    final small = big * 0.55;
    return GameScaffold(
      title: l.gameBattleship,
      children: [
        Text(
          _won == true
              ? l.gameYouWin
              : _won == false
                  ? l.gameYouLose
                  : (_msg.isEmpty ? l.gameBattleshipHint : _msg),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(l.gameEnemySea, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Center(child: _grid(_enemy, enemy: true, cell: big)),
        const SizedBox(height: 16),
        Text(l.gameYourSea, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Center(child: _grid(_mine, enemy: false, cell: small)),
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

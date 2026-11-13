import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/battleship_logic.dart';
import '../services/game_sound.dart';

enum _Phase { placing, playing }

class BattleshipScreen extends StatefulWidget {
  final Difficulty difficulty;
  const BattleshipScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<BattleshipScreen> createState() => _BattleshipScreenState();
}

class _BattleshipScreenState extends State<BattleshipScreen> with TickerProviderStateMixin {
  final _rand = Random();
  late BattleshipBoard _enemy;
  late BattleshipBoard _mine;
  _Phase _phase = _Phase.placing;
  bool _horizontal = true;
  bool _busy = false; // colpo in volo o turno dell'avversario (input bloccato)
  bool _enemyTurn = false; // spara il telefono
  bool? _won; // null = in corso
  String _msg = '';

  // Animazione del colpo (missile + esplosione/spruzzo) su ciascuna griglia.
  late final AnimationController _fxEnemy =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
  late final AnimationController _fxMine =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
  int? _fxEnemyCell;
  int? _fxMineCell;
  bool _fxEnemyHit = false;
  bool _fxMineHit = false;

  int get _aiLevel => widget.difficulty.index;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _fxEnemy.dispose();
    _fxMine.dispose();
    super.dispose();
  }

  void _reset() {
    _enemy = BattleshipBoard.random(_rand);
    _mine = BattleshipBoard();
    _phase = _Phase.placing;
    _horizontal = true;
    _busy = false;
    _enemyTurn = false;
    _won = null;
    _msg = '';
    _fxEnemyCell = null;
    _fxMineCell = null;
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
    GameSound.instance.play(Sfx.place);
    setState(() {});
  }

  void _randomize() => setState(() {
        GameSound.instance.play(Sfx.flip);
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
    // Colpo in volo: il risultato è già noto, ma si applica quando arriva.
    setState(() {
      _busy = true;
      _fxEnemyCell = idx;
      _fxEnemyHit = _enemy.ship[idx] != -1;
    });
    await _fxEnemy.forward(from: 0);
    if (!mounted) return;
    final hit = _enemy.fire(idx);
    GameSound.instance.play(hit ? Sfx.explosion : Sfx.splash);
    setState(() {
      _msg = '${l.gameYou}: ${_resultText(l, _enemy, idx, hit)}';
      if (_enemy.allSunk) _won = true;
    });
    if (_won != null) {
      setState(() => _busy = false);
      return;
    }
    setState(() => _enemyTurn = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final shot = BattleshipAi.nextShot(_mine, _rand, level: _aiLevel);
    setState(() {
      _fxMineCell = shot;
      _fxMineHit = _mine.ship[shot] != -1;
    });
    await _fxMine.forward(from: 0);
    if (!mounted) return;
    final h = _mine.fire(shot);
    GameSound.instance.play(h ? Sfx.explosion : Sfx.splash);
    setState(() {
      _msg = '$_msg   ·   ${l.gameOpponent}: ${_resultText(l, _mine, shot, h)}';
      if (_mine.allSunk) _won = false;
      _busy = false;
      _enemyTurn = false;
    });
  }

  // ------------------------------------------------------------------------ UI
  Widget _grid(
    BattleshipBoard b, {
    required bool enemy,
    required double cell,
    required void Function(int) onTap,
    AnimationController? fx,
    int? fxCell,
    bool fxHit = false,
  }) {
    final side = cell * BattleshipBoard.size;
    return SizedBox(
      width: side,
      height: side,
      child: Stack(
        children: [
          GridView.count(
            crossAxisCount: BattleshipBoard.size,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < BattleshipBoard.size * BattleshipBoard.size; i++)
                _cell(b, i, enemy, onTap),
            ],
          ),
          // Navi: le mie sempre visibili, quelle nemiche solo se affondate.
          IgnorePointer(
            child: CustomPaint(
              size: Size(side, side),
              painter: _ShipsPainter(b, cell, revealAll: !enemy),
            ),
          ),
          // Missile, esplosione o spruzzo
          if (fx != null && fxCell != null)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: fx,
                builder: (context, _) => CustomPaint(
                  size: Size(side, side),
                  painter: _ShotFxPainter(fxCell, cell, fx.value, fxHit, fromBottom: enemy),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(BattleshipBoard b, int i, bool enemy, void Function(int) onTap) {
    final shot = b.shot[i];
    final isShip = b.ship[i] != -1;
    final sunk = isShip && b.isSunk(b.ship[i]);
    // Mare nemico rosso chiaro, il mio blu.
    final sea = enemy ? const Color(0xFFF2B8B5) : Colors.lightBlue.shade200;
    Color color = sea;
    Widget? child;
    if (shot && isShip) {
      color = sunk ? Colors.red.shade900.withOpacity(0.55) : Colors.deepOrange.withOpacity(0.45);
      child = const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 18);
    } else if (shot) {
      color = enemy ? const Color(0xFFFBE3E1) : Colors.lightBlue.shade50;
      child = Icon(Icons.circle, size: 6, color: enemy ? Colors.red.shade200 : Colors.blueGrey);
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
                  label: Text(_shipName(l, id)),
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
                child: GameButton(
                  primary: false,
                  onPressed: () => setState(() => _horizontal = !_horizontal),
                  icon: _horizontal ? Icons.swap_horiz_rounded : Icons.swap_vert_rounded,
                  label: _horizontal ? l.gameHorizontal : l.gameVertical,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GameButton(
                  primary: false,
                  onPressed: _randomize,
                  icon: Icons.casino_rounded,
                  label: l.gameRandom,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GameButton(
            onPressed: _mine.allPlaced ? _start : null,
            icon: Icons.play_arrow_rounded,
            label: l.gameStart,
          ),
        ],
      );
    }

    final over = _won != null;
    final Widget status = over
        ? ResultBanner(
            key: ValueKey('over-$_won'),
            text: _won! ? l.gameYouWin : l.gameYouLose,
            kind: _won! ? ResultKind.win : ResultKind.lose,
          )
        : _enemyTurn
            ? _banner(l.gameEnemyTurn, Colors.orange.shade700, Colors.white, Icons.hourglass_top_rounded)
            : _banner(l.gameFire, Colors.green.shade600, Colors.white, Icons.gps_fixed_rounded);

    return GameScaffold(
      title: l.gameBattleship,
      celebrate: _won == true,
      children: [
        StatusSlot(child: status),
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
            opacity: (_enemyTurn || over) ? 0.55 : 1,
            child: _grid(_enemy,
                enemy: true,
                cell: big,
                onTap: _fire,
                fx: _fxEnemy,
                fxCell: _fxEnemyCell,
                fxHit: _fxEnemyHit),
          ),
        ),
        const SizedBox(height: 16),
        Text(l.gameYourSea, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Center(
          child: _grid(_mine,
              enemy: false,
              cell: small,
              onTap: (_) {},
              fx: _fxMine,
              fxCell: _fxMineCell,
              fxHit: _fxMineHit),
        ),
        const SizedBox(height: 16),
        GameButton(
          onPressed: () => setState(_reset),
          icon: Icons.refresh_rounded,
          label: l.gameNew,
        ),
      ],
    );
  }

  String _shipName(AppLocalizations l, int id) =>
      id == 0 ? l.shipCarrier : (id <= 2 ? l.shipDestroyer : l.shipPatrol);
}

// ============================================================ disegno delle navi
/// Naviglio visto dall'alto: portaerei (4), cacciatorpediniere (3), motovedetta (2).
class _ShipsPainter extends CustomPainter {
  final BattleshipBoard board;
  final double cell;
  final bool revealAll;
  _ShipsPainter(this.board, this.cell, {required this.revealAll});

  @override
  void paint(Canvas canvas, Size size) {
    const n = BattleshipBoard.size;
    for (var id = 0; id < board.shipCells.length; id++) {
      final cells = board.shipCells[id];
      if (cells.isEmpty) continue;
      if (!revealAll && !board.isSunk(id)) continue;
      final sorted = [...cells]..sort();
      final first = sorted.first, last = sorted.last;
      final horizontal = cells.length > 1 ? (last - first) < n : true;
      final x0 = (first % n) * cell, y0 = (first ~/ n) * cell;
      final len = cells.length;
      final rect = horizontal
          ? Rect.fromLTWH(x0, y0, len * cell, cell)
          : Rect.fromLTWH(x0, y0, cell, len * cell);
      final sunk = board.isSunk(id);
      canvas.save();
      canvas.clipRect(rect.inflate(1));
      if (!horizontal) {
        canvas.translate(rect.left + rect.width, rect.top);
        canvas.rotate(pi / 2);
      } else {
        canvas.translate(rect.left, rect.top);
      }
      _ship(canvas, len * cell, cell, len, sunk);
      canvas.restore();
    }
  }

  /// Si disegna sempre in orizzontale, prua a destra.
  void _ship(Canvas canvas, double w, double h, int len, bool sunk) {
    final hullColor = sunk ? const Color(0xFF5B3A36) : const Color(0xFF5E7083);
    final deck = sunk ? const Color(0xFF7A5A55) : const Color(0xFF93A4B5);
    final hull = Path()
      ..moveTo(h * 0.12, h * 0.2)
      ..lineTo(w - h * 0.42, h * 0.2)
      ..quadraticBezierTo(w - h * 0.06, h * 0.32, w - h * 0.04, h * 0.5)
      ..quadraticBezierTo(w - h * 0.06, h * 0.68, w - h * 0.42, h * 0.8)
      ..lineTo(h * 0.12, h * 0.8)
      ..quadraticBezierTo(h * 0.02, h * 0.5, h * 0.12, h * 0.2)
      ..close();
    canvas.drawPath(hull.shift(const Offset(0, 1.5)), Paint()..color = Colors.black26);
    canvas.drawPath(hull, Paint()..color = hullColor);
    // ponte
    final deckRect = Rect.fromLTWH(h * 0.2, h * 0.28, w - h * 0.2 - h * 0.62, h * 0.44);
    canvas.drawRRect(
        RRect.fromRectAndRadius(deckRect, Radius.circular(h * 0.1)), Paint()..color = deck);
    final detail = Paint()..color = Colors.black.withOpacity(0.35);
    final light = Paint()..color = Colors.white.withOpacity(0.7);
    if (len == 4) {
      // Portaerei: pista con linea tratteggiata e torre di comando
      for (var i = 0; i < 5; i++) {
        canvas.drawRect(
            Rect.fromLTWH(deckRect.left + 6 + i * (deckRect.width - 12) / 5, h * 0.485,
                (deckRect.width - 12) / 10, h * 0.03),
            light);
      }
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(deckRect.left + deckRect.width * 0.55, h * 0.2, h * 0.3, h * 0.13),
              const Radius.circular(3)),
          Paint()..color = hullColor);
    } else if (len == 3) {
      // Cacciatorpediniere: torrette cannoni e plancia
      canvas.drawCircle(Offset(deckRect.left + deckRect.width * 0.2, h / 2), h * 0.13, detail);
      canvas.drawCircle(Offset(deckRect.left + deckRect.width * 0.78, h / 2), h * 0.13, detail);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(deckRect.left + deckRect.width * 0.5, h / 2),
                  width: h * 0.3,
                  height: h * 0.26),
              const Radius.circular(3)),
          Paint()..color = hullColor);
    } else {
      // Motovedetta: piccola cabina
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(deckRect.left + deckRect.width * 0.55, h / 2),
                  width: h * 0.34,
                  height: h * 0.3),
              const Radius.circular(3)),
          Paint()..color = hullColor);
    }
    if (sunk) {
      canvas.drawLine(Offset(h * 0.2, h * 0.2), Offset(w - h * 0.2, h * 0.8),
          Paint()..color = Colors.red.shade300..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _ShipsPainter old) => true;
}

// =========================================================== animazione del colpo
class _ShotFxPainter extends CustomPainter {
  final int cellIndex;
  final double cell;
  final double t; // 0..1
  final bool hit;
  final bool fromBottom; // sul mare nemico il missile parte dal basso (il mio lato)
  _ShotFxPainter(this.cellIndex, this.cell, this.t, this.hit, {required this.fromBottom});

  @override
  void paint(Canvas canvas, Size size) {
    const n = BattleshipBoard.size;
    final target = Offset((cellIndex % n + 0.5) * cell, (cellIndex ~/ n + 0.5) * cell);
    final start = Offset(size.width / 2, fromBottom ? size.height + cell : -cell);
    const flight = 0.55;
    if (t < flight) {
      // Missile lungo una traiettoria leggermente curva, con scia
      final k = Curves.easeIn.transform(t / flight);
      Offset at(double u) {
        final p = Offset.lerp(start, target, u)!;
        final bend = sin(u * pi) * cell * 0.9 * (target.dx > size.width / 2 ? -1 : 1);
        return Offset(p.dx + bend, p.dy);
      }

      final pos = at(k);
      final back = at(max(0, k - 0.18));
      canvas.drawLine(
        back,
        pos,
        Paint()
          ..shader = LinearGradient(colors: [Colors.transparent, Colors.orangeAccent])
              .createShader(Rect.fromPoints(back, pos))
          ..strokeWidth = cell * 0.22
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(pos, cell * 0.17, Paint()..color = Colors.grey.shade800);
      canvas.drawCircle(pos, cell * 0.08, Paint()..color = Colors.yellowAccent);
      return;
    }
    final u = (t - flight) / (1 - flight);
    if (hit) {
      // Piccola esplosione: palla di fuoco che si espande e svanisce
      final r = cell * (0.2 + 0.55 * Curves.easeOut.transform(u));
      final alpha = (1 - u).clamp(0.0, 1.0);
      canvas.drawCircle(target, r, Paint()..color = Colors.deepOrange.withOpacity(0.85 * alpha));
      canvas.drawCircle(target, r * 0.6, Paint()..color = Colors.yellow.withOpacity(alpha));
      canvas.drawCircle(target, r * 0.25, Paint()..color = Colors.white.withOpacity(alpha));
      final spark = Paint()
        ..color = Colors.orangeAccent.withOpacity(alpha)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 8; i++) {
        final a = i * pi / 4;
        canvas.drawLine(
          target + Offset(cos(a), sin(a)) * r,
          target + Offset(cos(a), sin(a)) * (r + cell * 0.25 * u),
          spark,
        );
      }
    } else {
      // Spruzzo: onde concentriche e gocce
      final alpha = (1 - u).clamp(0.0, 1.0);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(0.9 * alpha);
      canvas.drawCircle(target, cell * (0.15 + 0.5 * u), ring);
      canvas.drawCircle(target, cell * (0.05 + 0.32 * u), ring);
      final drop = Paint()..color = Colors.lightBlue.shade100.withOpacity(alpha);
      for (var i = 0; i < 6; i++) {
        final a = i * pi / 3 + 0.3;
        final h = sin(u * pi) * cell * 0.45;
        canvas.drawCircle(
            target + Offset(cos(a) * cell * 0.3 * u, -h + sin(a) * cell * 0.1), cell * 0.05, drop);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShotFxPainter old) => old.t != t || old.cellIndex != cellIndex;
}

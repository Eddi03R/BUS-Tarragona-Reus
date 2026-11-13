import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/checkers_logic.dart';

/// Dama italiana contro il telefono (tu hai i bianchi, in basso). Tocca una
/// pedina e poi la casella di arrivo; se la presa continua, tocca le caselle
/// una dopo l'altra. La presa è obbligatoria.
class CheckersScreen extends StatefulWidget {
  final Difficulty difficulty;
  const CheckersScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<CheckersScreen> createState() => _CheckersScreenState();
}

class _CheckersScreenState extends State<CheckersScreen> {
  CheckersState _s = CheckersState.start();
  int? _sel;
  List<int> _prefix = []; // caselle già toccate dopo la partenza (prese multiple)
  CheckersMove? _last;
  bool _thinking = false;
  bool _over = false;
  bool? _humanWon; // null = pareggio
  final _rand = Random();

  String get _winsKey => 'checkers_wins_${widget.difficulty.name}';
  int get _level => widget.difficulty.index;
  bool get _humanTurn => _s.white && !_thinking && !_over;

  void _newGame() => setState(() {
        _s = CheckersState.start();
        _sel = null;
        _prefix = [];
        _last = null;
        _thinking = false;
        _over = false;
        _humanWon = null;
      });

  List<CheckersMove> get _candidates {
    if (_sel == null) return const [];
    final pre = [_sel!, ..._prefix];
    return [
      for (final m in _s.legalMoves())
        if (m.path.length >= pre.length && _startsWith(m.path, pre)) m
    ];
  }

  static bool _startsWith(List<int> a, List<int> pre) {
    for (var i = 0; i < pre.length; i++) {
      if (a[i] != pre[i]) return false;
    }
    return true;
  }

  Set<int> get _nextSquares {
    final pre = 1 + _prefix.length;
    return {for (final m in _candidates) if (m.path.length > pre) m.path[pre]};
  }

  void _tap(Offset p, double side) {
    if (!_humanTurn) return;
    final cell = side / 8;
    final sq = (p.dy ~/ cell).clamp(0, 7) * 8 + (p.dx ~/ cell).clamp(0, 7);
    if (_sel != null && _nextSquares.contains(sq)) {
      final pre = [_sel!, ..._prefix, sq];
      final done = _candidates.where((m) => m.path.length == pre.length && _startsWith(m.path, pre));
      if (done.isNotEmpty) {
        _play(done.first);
      } else {
        setState(() => _prefix = [..._prefix, sq]);
      }
      return;
    }
    if (_prefix.isEmpty && _s.b[sq] > 0 && _s.legalMoves().any((m) => m.from == sq)) {
      setState(() => _sel = sq);
    } else if (_prefix.isEmpty) {
      setState(() => _sel = null);
    }
  }

  void _play(CheckersMove m) {
    setState(() {
      _s = _s.apply(m);
      _last = m;
      _sel = null;
      _prefix = [];
    });
    _afterMove();
  }

  Future<void> _afterMove() async {
    if (_finishIfOver()) return;
    if (_s.white) return;
    setState(() => _thinking = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final m = CheckersAi.bestMove(_s, _level, _rand);
    if (m == null) {
      setState(() => _thinking = false);
      _finishIfOver();
      return;
    }
    setState(() {
      _s = _s.apply(m);
      _last = m;
      _thinking = false;
    });
    _finishIfOver();
  }

  bool _finishIfOver() {
    final w = _s.winner;
    final draw = _s.isDraw;
    if (w == null && !draw) return false;
    setState(() {
      _over = true;
      _humanWon = draw ? null : w;
    });
    if (!draw && w == true) {
      GameStats.instance.setValue(_winsKey, GameStats.instance.value(_winsKey) + 1).then((_) {
        if (mounted) setState(() {});
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final wins = GameStats.instance.value(_winsKey);
    final mustCapture = _humanTurn && _s.legalMoves().any((m) => m.isCapture);

    Widget status;
    if (_over) {
      status = ResultBanner(
        key: ValueKey('dama-$_humanWon'),
        text: _humanWon == null ? l.gameDraw : (_humanWon! ? l.gameYouWin : l.gameYouLose),
        kind: _humanWon == null ? ResultKind.neutral : (_humanWon! ? ResultKind.win : ResultKind.lose),
      );
    } else if (_thinking) {
      status = Text(l.gameThinking, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
    } else if (mustCapture) {
      status = Text(l.gameMustCapture,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.orange.shade800));
    } else {
      status = Text(l.gameYourTurn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
    }

    final movable = <int>{
      if (mustCapture) for (final m in _s.legalMoves()) m.from,
    };
    return GameScaffold(
      title: l.gameCheckers,
      celebrate: _over && _humanWon == true,
      guardBack: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(difficultyLabel(l, widget.difficulty),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(l.gameWins(wins), style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(child: status),
        LayoutBuilder(builder: (context, box) {
          final side = box.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _tap(d.localPosition, side),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: side,
                height: side,
                child: CustomPaint(
                  painter: _DamaPainter(
                    _s,
                    _humanTurn ? _sel : null,
                    _prefix,
                    _nextSquares,
                    _last,
                    movable,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
      bottom: GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
    );
  }
}

class _DamaPainter extends CustomPainter {
  final CheckersState s;
  final int? sel;
  final List<int> prefix;
  final Set<int> next;
  final CheckersMove? last;
  final Set<int> movable;
  _DamaPainter(this.s, this.sel, this.prefix, this.next, this.last, this.movable);

  static const _light = Color(0xFFEAD7B1), _dark = Color(0xFF7B4B2A);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 8;
    for (var sq = 0; sq < 64; sq++) {
      final r = sq ~/ 8, f = sq % 8;
      final rect = Rect.fromLTWH(f * cell, r * cell, cell, cell);
      canvas.drawRect(rect, Paint()..color = (r + f) % 2 == 0 ? _light : _dark);
      if (last != null && (last!.path.contains(sq))) {
        canvas.drawRect(rect, Paint()..color = const Color(0x55FFEB3B));
      }
      if (sq == sel || prefix.contains(sq)) canvas.drawRect(rect, Paint()..color = const Color(0x8869B4FF));
    }
    for (var sq = 0; sq < 64; sq++) {
      final p = s.b[sq];
      if (p == 0) continue;
      final r = sq ~/ 8, f = sq % 8;
      final c = Offset(f * cell + cell / 2, r * cell + cell / 2);
      final rad = cell * 0.38;
      final white = p > 0;
      canvas.drawCircle(c + Offset(0, cell * 0.04), rad, Paint()..color = const Color(0x55000000));
      canvas.drawCircle(c, rad, Paint()..color = white ? const Color(0xFFF7EFDD) : const Color(0xFF3A2A25));
      canvas.drawCircle(
          c,
          rad,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.05
            ..color = white ? const Color(0xFFB59B6D) : const Color(0xFF8C6A5B));
      canvas.drawCircle(
          c,
          rad * 0.62,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.035
            ..color = white ? const Color(0xFFD9C79F) : const Color(0xFF5B433B));
      if (p.abs() == 2) _crown(canvas, c, rad * 0.55);
      if (movable.contains(sq)) {
        canvas.drawCircle(
            c,
            rad + cell * 0.05,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = cell * 0.06
              ..color = const Color(0xFFFF9800));
      }
    }
    for (final sq in next) {
      final r = sq ~/ 8, f = sq % 8;
      canvas.drawCircle(Offset(f * cell + cell / 2, r * cell + cell / 2), cell * 0.16,
          Paint()..color = const Color(0xCC43A047));
    }
  }

  void _crown(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx - r, c.dy + r * 0.6)
      ..lineTo(c.dx - r, c.dy - r * 0.5)
      ..lineTo(c.dx - r * 0.45, c.dy + r * 0.05)
      ..lineTo(c.dx, c.dy - r * 0.75)
      ..lineTo(c.dx + r * 0.45, c.dy + r * 0.05)
      ..lineTo(c.dx + r, c.dy - r * 0.5)
      ..lineTo(c.dx + r, c.dy + r * 0.6)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFC107));
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF8D6E00));
  }

  @override
  bool shouldRepaint(covariant _DamaPainter old) => true;
}

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'chess_pieces.dart';
import 'game_common.dart';
import 'logic/chess_logic.dart';
import '../services/game_sound.dart';

/// Scacchi contro il telefono (tu hai i bianchi). Tocca un pezzo e poi la
/// casella di arrivo. Tre livelli: più sale il livello, più mosse "vede" avanti.
class ChessScreen extends StatefulWidget {
  final Difficulty difficulty;
  const ChessScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  ChessState _s = ChessState.start();
  int? _sel;
  List<ChessMove> _targets = [];
  ChessMove? _last;
  bool _thinking = false;
  ChessOutcome? _outcome;
  bool _won = false;

  String get _winsKey => 'chess_wins_${widget.difficulty.name}';
  int get _level => widget.difficulty.index;
  bool get _humanTurn => _s.white && !_thinking && _outcome == null;

  void _newGame() => setState(() {
        _s = ChessState.start();
        _sel = null;
        _targets = [];
        _last = null;
        _thinking = false;
        _outcome = null;
        _won = false;
      });

  void _tap(Offset p, double side) {
    if (!_humanTurn) return;
    final cell = side / 8;
    final c = (p.dx ~/ cell).clamp(0, 7), r = (p.dy ~/ cell).clamp(0, 7);
    final sq = r * 8 + c;
    final hits = _targets.where((m) => m.to == sq).toList();
    if (_sel != null && hits.isNotEmpty) {
      _choose(hits);
      return;
    }
    if (_s.b[sq] > 0) {
      GameSound.instance.play(Sfx.tap);
      setState(() {
        _sel = sq;
        _targets = _s.movesFrom(sq);
      });
    } else {
      setState(() {
        _sel = null;
        _targets = [];
      });
    }
  }

  Future<void> _choose(List<ChessMove> hits) async {
    var m = hits.first;
    if (hits.length > 1) {
      // promozione: scegli il pezzo
      final pick = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.gamePromote),
          content: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: [
              for (final pc in const [5, 4, 3, 2])
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(ctx).pop(pc),
                  child: Padding(padding: const EdgeInsets.all(6), child: ChessPieceIcon(pc, size: 46)),
                ),
            ],
          ),
        ),
      );
      if (pick == null || !mounted) return;
      m = hits.firstWhere((x) => x.promo == pick);
    }
    _play(m);
  }

  void _play(ChessMove m) {
    GameSound.instance.play(_s.b[m.to] != 0 ? Sfx.capture : Sfx.place);
    setState(() {
      _s = _s.apply(m);
      _last = m;
      _sel = null;
      _targets = [];
    });
    _afterMove();
  }

  Future<void> _afterMove() async {
    final out = _s.outcome;
    if (out != null) {
      setState(() => _outcome = out);
      if (out == ChessOutcome.checkmate && !_s.white) {
        _won = true;
        await GameStats.instance.setValue(_winsKey, GameStats.instance.value(_winsKey) + 1);
        if (mounted) setState(() {});
      }
      return;
    }
    if (_s.white) return; // tocca all'umano
    setState(() => _thinking = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final res = await compute(ChessAi.searchFen, <Object>[_s.toFen(), _level]);
    if (!mounted) return;
    if (res == null) {
      setState(() => _thinking = false);
      return;
    }
    final m = ChessMove(res[0], res[1], res[2]);
    GameSound.instance.play(_s.b[m.to] != 0 ? Sfx.capture : Sfx.place2);
    setState(() {
      _s = _s.apply(m);
      _last = m;
      _thinking = false;
    });
    final out2 = _s.outcome;
    if (out2 != null) setState(() => _outcome = out2);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final wins = GameStats.instance.value(_winsKey);
    final check = _outcome == null && _s.inCheck();

    Widget status;
    if (_outcome != null) {
      final text = switch (_outcome!) {
        ChessOutcome.checkmate => _won ? l.gameYouWin : l.gameYouLose,
        ChessOutcome.stalemate => l.gameStalemate,
        ChessOutcome.drawFifty || ChessOutcome.drawMaterial => l.gameDraw,
      };
      status = ResultBanner(
        key: ValueKey('chess-$_outcome-$_won'),
        text: text,
        kind: _outcome == ChessOutcome.checkmate
            ? (_won ? ResultKind.win : ResultKind.lose)
            : ResultKind.neutral,
      );
    } else {
      final text = _thinking ? l.gameThinking : (check ? l.gameCheck : l.gameYourTurn);
      status = Text(text,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: check && !_thinking ? scheme.error : scheme.onSurface));
    }

    return GameScaffold(
      title: l.gameChess,
      celebrate: _won,
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
                  painter: _BoardPainter(_s, _sel, _targets, _last, check ? _s.b.indexOf(_s.white ? 6 : -6) : -1),
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

class _BoardPainter extends CustomPainter {
  final ChessState s;
  final int? sel;
  final List<ChessMove> targets;
  final ChessMove? last;
  final int checkSq;
  _BoardPainter(this.s, this.sel, this.targets, this.last, this.checkSq);

  static const _light = Color(0xFFF0D9B5), _dark = Color(0xFFB58863);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 8;
    final targetSquares = {for (final m in targets) m.to};
    for (var sq = 0; sq < 64; sq++) {
      final r = sq ~/ 8, f = sq % 8;
      final rect = Rect.fromLTWH(f * cell, r * cell, cell, cell);
      canvas.drawRect(rect, Paint()..color = (r + f) % 2 == 0 ? _light : _dark);
      if (last != null && (sq == last!.from || sq == last!.to)) {
        canvas.drawRect(rect, Paint()..color = const Color(0x66FFEB3B));
      }
      if (sq == sel) canvas.drawRect(rect, Paint()..color = const Color(0x8869B4FF));
      if (sq == checkSq) {
        canvas.drawRect(
            rect,
            Paint()
              ..shader = const RadialGradient(colors: [Color(0xCCFF1744), Color(0x00FF1744)])
                  .createShader(rect));
      }
    }
    // coordinate
    for (var i = 0; i < 8; i++) {
      final dark = (7 + i) % 2 == 0 ? _dark : _light;
      _label(canvas, 'abcdefgh'[i], Offset(i * cell + cell - 9, 8 * cell - 12), dark == _dark ? _light : _dark, cell);
      final dark2 = (i + 0) % 2 == 0 ? _light : _dark;
      _label(canvas, '${8 - i}', Offset(3, i * cell + 2), dark2 == _dark ? _light : _dark, cell);
    }
    for (var sq = 0; sq < 64; sq++) {
      final p = s.b[sq];
      if (p == 0) continue;
      final r = sq ~/ 8, f = sq % 8;
      paintChessPiece(canvas, p, Rect.fromLTWH(f * cell, r * cell, cell, cell).deflate(cell * 0.04));
    }
    for (final sq in targetSquares) {
      final r = sq ~/ 8, f = sq % 8;
      final c = Offset(f * cell + cell / 2, r * cell + cell / 2);
      if (s.b[sq] != 0) {
        canvas.drawCircle(
            c,
            cell * 0.46,
            Paint()
              ..color = const Color(0xAA2E7D32)
              ..style = PaintingStyle.stroke
              ..strokeWidth = cell * 0.09);
      } else {
        canvas.drawCircle(c, cell * 0.16, Paint()..color = const Color(0xAA2E7D32));
      }
    }
  }

  void _label(Canvas c, String t, Offset o, Color color, double cell) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(fontSize: cell * 0.2, fontWeight: FontWeight.w700, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, o);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}

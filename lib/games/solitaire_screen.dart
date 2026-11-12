import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import 'logic/solitaire_logic.dart';

/// Solitario (Klondike). Tocca una carta per selezionarla, poi tocca dove
/// metterla. Doppio tocco: la manda in automatico alla fondazione.
class SolitaireScreen extends StatefulWidget {
  const SolitaireScreen({super.key});

  @override
  State<SolitaireScreen> createState() => _SolitaireScreenState();
}

class _SolitaireScreenState extends State<SolitaireScreen> {
  static const _key = 'solitaire';
  final _rand = Random();
  final _watch = Stopwatch();
  Timer? _ticker;
  late SolitaireGame _g;
  final List<SolitaireGame> _history = [];
  SolSelection? _sel;
  bool _won = false;
  bool _newRecord = false;

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
      _g = SolitaireGame(_rand);
      _history.clear();
      _sel = null;
      _won = false;
      _newRecord = false;
    });
  }

  /// Esegue [f]; se cambia lo stato, ne salva prima una copia per "annulla".
  bool _record(bool Function() f) {
    final snap = _g.copy();
    final ok = f();
    if (ok) {
      _history.add(snap);
      if (_history.length > 60) _history.removeAt(0);
    }
    return ok;
  }

  Future<void> _undo() async {
    final l = AppLocalizations.of(context)!;
    final ok = await RewardedOffer.ask(context,
        game: 'solitaire', action: 'undo', title: l.rewardedUndoTitle, message: l.rewardedUndoMessage);
    if (!ok || !mounted || _history.isEmpty) return;
    setState(() {
      for (var i = 0; i < 3 && _history.isNotEmpty; i++) {
        _g = _history.removeLast();
      }
      _sel = null;
    });
  }

  void _startClock() {
    if (_watch.isRunning) return;
    _watch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _afterMove() async {
    HapticFeedback.selectionClick();
    if (_g.won) {
      _watch.stop();
      _ticker?.cancel();
      final record = await GameStats.instance.submitBest(_key, _watch.elapsedMilliseconds);
      if (!mounted) return;
      setState(() {
        _won = true;
        _newRecord = record;
      });
    }
  }

  void _stock() {
    if (_won) return;
    _startClock();
    setState(() {
      _sel = null;
      _record(() {
        final before = _g.stock.length + _g.waste.length;
        _g.drawStock();
        return before > 0;
      });
    });
  }

  void _tapWaste() {
    if (_won || _g.waste.isEmpty) return;
    _startClock();
    const me = SolSelection(SolSource.waste, 0);
    if (_sel?.source == SolSource.waste) {
      // secondo tocco: prova la fondazione, altrimenti deseleziona
      final ok = _record(() => _g.moveToFoundation(me));
      setState(() => _sel = null);
      if (ok) _afterMove();
    } else {
      setState(() => _sel = me);
    }
  }

  void _tapFoundation(int f) {
    if (_won) return;
    final s = _sel;
    if (s == null) {
      if (_g.foundations[f].isNotEmpty) setState(() => _sel = SolSelection(SolSource.foundation, f));
      return;
    }
    final cards = _g.cardsOf(s);
    final ok = cards.length == 1 && cards.first.suit == f && _record(() => _g.moveToFoundation(s));
    setState(() => _sel = null);
    if (ok) _afterMove();
  }

  void _tapTableau(int col, int pos) {
    if (_won) return;
    _startClock();
    final pile = _g.tableau[col];
    final s = _sel;
    if (s != null) {
      // stessa carta toccata di nuovo: foundation automatica o deseleziona
      if (s.source == SolSource.tableau && s.index == col && s.from == pos) {
        final ok = _record(() => _g.moveToFoundation(s));
        setState(() => _sel = null);
        if (ok) _afterMove();
        return;
      }
      final ok = _record(() => _g.moveToTableau(s, col));
      if (ok) {
        setState(() => _sel = null);
        _afterMove();
        return;
      }
    }
    if (pos >= 0 && pos < pile.length) {
      if (!pile[pos].faceUp) {
        if (pos == pile.length - 1) {
          setState(() {
            _record(() {
              pile[pos].faceUp = true;
              return true;
            });
            _sel = null;
          });
        }
        return;
      }
      setState(() => _sel = SolSelection(SolSource.tableau, col, pos));
    } else {
      setState(() => _sel = null);
    }
  }

  bool _isSelected(SolSource src, int index, [int pos = 0]) {
    final s = _sel;
    if (s == null || s.source != src) return false;
    if (src == SolSource.tableau) return s.index == index && pos >= s.from;
    return s.index == index;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_key);
    return GameScaffold(
      title: l.gameSolitaire,
      celebrate: _won,
      guardBack: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fmtTime(_watch.elapsedMilliseconds),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(l.gameMoves(_g.moves)),
            Text(best == null ? l.gameNoRecord : l.gameBest(fmtTime(best))),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: const ValueKey('sol-won'),
                  text: _newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin,
                  kind: ResultKind.win)
              : Text(l.gameSolitaireHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        LayoutBuilder(builder: (context, box) {
          const gap = 4.0;
          final cw = (box.maxWidth - gap * 6) / 7;
          final ch = cw * 1.4;
          final up = ch * 0.30, down = ch * 0.13;
          // Zona delle colonne a altezza fissa (la pila più alta possibile): i
          // pulsanti sono in fondo alla pagina e non si spostano a ogni carta.
          final maxH = ch + 6 * down + 12 * up;
          return Column(
            children: [
              // riga alta: mazzo, scarti, fondazioni
              Row(
                children: [
                  _slot(cw, ch, _g.stock.isEmpty ? null : _back(cw, ch, scheme), _stock,
                      hint: _g.stock.isEmpty ? Icons.refresh_rounded : null, scheme: scheme),
                  const SizedBox(width: gap),
                  _slot(
                      cw,
                      ch,
                      _g.waste.isEmpty
                          ? null
                          : _face(_g.waste.last, cw, ch, _isSelected(SolSource.waste, 0)),
                      _tapWaste,
                      scheme: scheme),
                  SizedBox(width: gap + cw),
                  for (var f = 0; f < 4; f++) ...[
                    if (f > 0) const SizedBox(width: gap),
                    _slot(
                        cw,
                        ch,
                        _g.foundations[f].isEmpty
                            ? null
                            : _face(_g.foundations[f].last, cw, ch, _isSelected(SolSource.foundation, f)),
                        () => _tapFoundation(f),
                        label: SCard.suits[f],
                        scheme: scheme),
                  ],
                ],
              ),
              SizedBox(height: gap * 3),
              SizedBox(
                height: maxH,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var c = 0; c < 7; c++) ...[
                      if (c > 0) const SizedBox(width: gap),
                      SizedBox(
                        width: cw,
                        child: _column(c, cw, ch, up, down, scheme),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_won && _history.isNotEmpty && RewardedOffer.available) ...[
            HelpButton(
                freeIcon: Icons.undo_rounded, label: l.rewardedUndoButton, onPressed: _undo),
            const SizedBox(height: 10),
          ],
          GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
        ],
      ),
    );
  }

  Widget _column(int c, double cw, double ch, double up, double down, ColorScheme scheme) {
    final pile = _g.tableau[c];
    if (pile.isEmpty) {
      return GestureDetector(
        onTap: () => _tapTableau(c, -1),
        child: _emptySlot(cw, ch, scheme, label: 'K'),
      );
    }
    final children = <Widget>[];
    var y = 0.0;
    for (var i = 0; i < pile.length; i++) {
      final card = pile[i];
      children.add(Positioned(
        top: y,
        left: 0,
        width: cw,
        height: ch,
        child: GestureDetector(
          onTap: () => _tapTableau(c, i),
          child: card.faceUp
              ? _face(card, cw, ch, _isSelected(SolSource.tableau, c, i))
              : _back(cw, ch, scheme),
        ),
      ));
      y += card.faceUp ? up : down;
    }
    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _slot(double cw, double ch, Widget? card, VoidCallback onTap,
      {IconData? hint, String? label, required ColorScheme scheme}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cw,
        height: ch,
        child: card ?? _emptySlot(cw, ch, scheme, icon: hint, label: label),
      ),
    );
  }

  Widget _emptySlot(double cw, double ch, ColorScheme scheme, {IconData? icon, String? label}) {
    return Container(
      width: cw,
      height: ch,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant, width: 1.5),
        color: scheme.onSurface.withOpacity(0.04),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: scheme.onSurfaceVariant, size: cw * 0.5)
          : (label == null
              ? null
              : Text(label,
                  style: TextStyle(fontSize: cw * 0.5, color: scheme.outlineVariant))),
    );
  }

  Widget _back(double cw, double ch, ColorScheme scheme) {
    return Container(
      width: cw,
      height: ch,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.directions_bus_rounded, color: scheme.onPrimary.withOpacity(0.7), size: cw * 0.5),
    );
  }

  Widget _face(SCard c, double cw, double ch, bool selected) {
    final color = c.red ? const Color(0xFFD32F2F) : const Color(0xFF212121);
    return Container(
      width: cw,
      height: ch,
      padding: EdgeInsets.only(left: cw * 0.08, top: ch * 0.02),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF59D) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: selected ? const Color(0xFFFFA000) : Colors.black26, width: selected ? 2.5 : 1),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('${c.rankLabel}${c.suitLabel}',
              style: TextStyle(fontSize: cw * 0.38, fontWeight: FontWeight.w800, color: color)),
        ),
      ),
    );
  }
}

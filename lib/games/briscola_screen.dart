import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../services/game_sound.dart';
import 'briscola_cards.dart';
import 'game_common.dart';
import 'logic/briscola_logic.dart';

/// Briscola contro il telefono. Tocca una carta per giocarla.
class BriscolaScreen extends StatefulWidget {
  final Difficulty difficulty;
  const BriscolaScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<BriscolaScreen> createState() => _BriscolaScreenState();
}

class _BriscolaScreenState extends State<BriscolaScreen> {
  final _rand = Random();
  late BriscolaGame _g;
  bool _busy = false; // pausa tra una giocata e l'altra
  bool _thinking = false;
  bool _over = false;
  int _gen = 0; // annulla le attese di una partita già chiusa

  String get _winsKey => 'briscola_wins_${widget.difficulty.name}';
  bool get _humanTurn => !_busy && !_over && _g.turn == 0;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _gen++;
    setState(() {
      _g = BriscolaGame.deal(_rand, leader: _rand.nextInt(2));
      _busy = false;
      _thinking = false;
      _over = false;
    });
    if (_g.turn == 1) _aiPlay();
  }

  Future<bool> _wait(int ms) async {
    final gen = _gen;
    await Future<void>.delayed(Duration(milliseconds: ms));
    return mounted && gen == _gen;
  }

  void _tap(int i) {
    if (!_humanTurn) return;
    GameSound.instance.play(Sfx.place);
    setState(() => _g.play(0, i));
    _g.trickComplete ? _resolve() : _aiPlay();
  }

  Future<void> _aiPlay() async {
    setState(() {
      _busy = true;
      _thinking = true;
    });
    if (!await _wait(800)) return;
    final i = BriscolaAi.choose(_g, 1, widget.difficulty.index, _rand);
    GameSound.instance.play(Sfx.place2);
    setState(() {
      _g.play(1, i);
      _thinking = false;
    });
    if (_g.trickComplete) {
      _resolve();
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _resolve() async {
    setState(() => _busy = true);
    if (!await _wait(1200)) return;
    final winner = _g.resolveTrick();
    setState(() {});
    if (_g.isOver) {
      setState(() => _over = true);
      if (_g.winner == 0) {
        GameStats.instance.setValue(_winsKey, GameStats.instance.value(_winsKey) + 1).then((_) {
          if (mounted) setState(() {});
        });
      }
    } else if (winner == 1) {
      _aiPlay();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final wins = GameStats.instance.value(_winsKey);
    final res = _g.winner;

    final Widget status;
    if (_over) {
      status = ResultBanner(
        key: ValueKey('briscola-$_gen'),
        text: res == null ? l.gameDraw : (res == 0 ? l.gameYouWin : l.gameYouLose),
        kind: res == null ? ResultKind.neutral : (res == 0 ? ResultKind.win : ResultKind.lose),
      );
    } else if (_thinking) {
      status = Text(l.gameThinking, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
    } else if (_humanTurn) {
      status = Text(l.gameYourTurn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
    } else {
      status = const SizedBox.shrink();
    }

    return GameScaffold(
      title: l.gameBriscola,
      celebrate: _over && res == 0,
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
        const SizedBox(height: 4),
        Text(l.briscolaScore(_g.score[0], _g.score[1]),
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        StatusSlot(child: status),
        LayoutBuilder(builder: (context, box) {
          final cw = min(box.maxWidth * .23, 92.0), ch = cw * briscolaRatio;
          Widget slot(Widget? child) => SizedBox(width: cw, height: ch, child: child);
          return Column(
            children: [
              // mano del telefono (dorsi)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: slot(i < _g.hands[1].length ? BriscolaCardView(card: null, width: cw) : null),
                  ),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: ch * 1.4,
                child: Row(children: [
                  SizedBox(
                    width: cw * 2.5,
                    child: Stack(children: [
                      if (!_g.trumpTaken)
                        Positioned(
                          left: cw * .6,
                          top: ch * .1,
                          child: RotatedBox(
                              quarterTurns: 1, child: BriscolaCardView(card: _g.trumpCard, width: cw)),
                        ),
                      if (_g.drawsLeft > (_g.trumpTaken ? 0 : 1))
                        Positioned(left: 0, top: 0, child: BriscolaCardView(card: null, width: cw)),
                      Positioned(
                        left: 0,
                        top: ch + 6,
                        child: Row(children: [
                          BriscolaSuitIcon(suit: _g.trump, size: 22),
                          const SizedBox(width: 6),
                          Text('${_g.drawsLeft}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: cw * 1.5,
                        height: ch * 1.3,
                        child: Stack(children: [
                          if (_g.table[1] != null)
                            Positioned(left: 0, top: 0, child: BriscolaCardView(card: _g.table[1], width: cw)),
                          if (_g.table[0] != null)
                            Positioned(
                                right: 0, bottom: 0, child: BriscolaCardView(card: _g.table[0], width: cw)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              // la tua mano
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: slot(i < _g.hands[0].length
                        ? GestureDetector(
                            onTap: () => _tap(i),
                            child: Opacity(
                              opacity: _humanTurn ? 1 : .75,
                              child: BriscolaCardView(card: _g.hands[0][i], width: cw),
                            ),
                          )
                        : null),
                  ),
              ]),
            ],
          );
        }),
      ],
      bottom: GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
    );
  }
}

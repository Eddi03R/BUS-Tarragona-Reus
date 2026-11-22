import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../services/game_sound.dart';
import 'briscola_cards.dart';
import 'game_common.dart';
import 'logic/briscola_logic.dart';

/// Briscola contro il telefono. Tocca una carta per giocarla.
/// Le carte si animano: pescata dal mazzo (con giro), lancio sul tavolo,
/// presa verso chi vince la mano.
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
  int _humanSlot = 1; // da quale posto della mano è partita la carta lanciata
  int _aiSlot = 1;
  int? _collect; // chi sta prendendo la mano (animazione di presa)

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
      _collect = null;
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
    setState(() {
      _humanSlot = i;
      _g.play(0, i);
    });
    _g.trickComplete ? _resolve() : _aiPlay();
  }

  Future<void> _aiPlay() async {
    setState(() {
      _busy = true;
      _thinking = true;
    });
    if (!await _wait(900)) return;
    final i = BriscolaAi.choose(_g, 1, widget.difficulty.index, _rand);
    GameSound.instance.play(Sfx.place2);
    setState(() {
      _aiSlot = i;
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
    if (!await _wait(1100)) return; // si guardano le due carte
    final lead = _g.table[_g.leader]!, reply = _g.table[1 - _g.leader]!;
    final takes = BriscolaGame.followerWins(lead, reply, _g.trump) ? 1 - _g.leader : _g.leader;
    setState(() => _collect = takes); // le carte scivolano da chi le prende
    if (!await _wait(450)) return;
    final winner = _g.resolveTrick();
    setState(() => _collect = null);
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

  ValueKey<String> _key(BCard c) => ValueKey('$_gen-${c.suit}-${c.rank}');

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
          final w = box.maxWidth;
          final cw = min(w * .23, 92.0), ch = cw * briscolaRatio;
          const gap = 8.0; // distanza tra le carte in mano
          // Coordinate dei posti, rispetto al centro della riga: la mano ha 3 posti fissi.
          double slotX(int i) => w / 2 + (i - 1) * (cw + gap) - cw / 2;
          // Il tavolo (due carte sovrapposte) sta a destra del mazzo; i centri sono
          // calcolati qui così le animazioni partono dal punto giusto.
          final tableX = w / 2 + cw * .5; // angolo sinistro del riquadro del tavolo
          final humanTable = Offset(tableX + cw, ch * .85); // centro carta lanciata da te
          final aiTable = Offset(tableX + cw / 2, ch * .55); // centro carta del telefono
          final handY = ch * 1.4 + gap + ch / 2; // centro delle carte in mano (stesse coord. del tavolo)
          final aiHandY = -(12 + ch / 2); // centro della mano del telefono
          final deckC = Offset(cw / 2, ch / 2); // centro del mazzo

          Widget aiBacks() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: gap / 2),
                    child: SizedBox(
                        width: cw,
                        height: ch,
                        child: i < _g.hands[1].length ? BriscolaCardView(card: null, width: cw) : null),
                  ),
              ]);

          return Column(
            children: [
              aiBacks(),
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
                      child: AnimatedSlide(
                        duration: _collect == null ? Duration.zero : const Duration(milliseconds: 420),
                        curve: Curves.easeIn,
                        offset: _collect == null ? Offset.zero : Offset(0, _collect == 0 ? 1.7 : -1.7),
                        child: AnimatedOpacity(
                          duration: _collect == null ? Duration.zero : const Duration(milliseconds: 420),
                          opacity: _collect == null ? 1 : 0,
                          child: SizedBox(
                            width: cw * 1.5,
                            height: ch * 1.3,
                            child: Stack(children: [
                              if (_g.table[1] != null)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: _Fly(
                                    key: _key(_g.table[1]!),
                                    from: Offset(w / 2 + (_aiSlot - 1) * (cw + gap), aiHandY) - aiTable,
                                    angle: .35,
                                    flipFrom: true,
                                    card: _g.table[1]!,
                                    width: cw,
                                  ),
                                ),
                              if (_g.table[0] != null)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: _Fly(
                                    key: _key(_g.table[0]!),
                                    from: Offset(w / 2 + (_humanSlot - 1) * (cw + gap), handY) - humanTable,
                                    angle: -.3,
                                    card: _g.table[0]!,
                                    width: cw,
                                  ),
                                ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: gap),
              // la tua mano: i posti sono fissi, le carte scorrono al loro posto e si pescano dal mazzo
              SizedBox(
                height: ch,
                width: w,
                child: Stack(children: [
                  for (var i = 0; i < _g.hands[0].length; i++)
                    AnimatedPositioned(
                      key: _key(_g.hands[0][i]),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                      left: slotX(i),
                      top: 0,
                      child: _Fly(
                        from: deckC - Offset(slotX(i) + cw / 2, handY),
                        angle: 0,
                        flipFrom: true,
                        card: _g.hands[0][i],
                        width: cw,
                        onTap: () => _tap(i),
                        dim: !_humanTurn,
                      ),
                    ),
                ]),
              ),
            ],
          );
        }),
      ],
      bottom: GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
    );
  }
}

/// Carta che arriva al suo posto volando da [from] (spostamento di partenza) e,
/// con [flipFrom], girandosi da dorso a faccia.
class _Fly extends StatelessWidget {
  final Offset from;
  final double angle;
  final bool flipFrom;
  final BCard card;
  final double width;
  final VoidCallback? onTap;
  final bool dim;
  const _Fly({
    super.key,
    required this.from,
    required this.angle,
    this.flipFrom = false,
    required this.card,
    required this.width,
    this.onTap,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final a = t * pi;
        final back = flipFrom && a < pi / 2;
        final sx = flipFrom ? cos(a).abs().clamp(0.02, 1.0) : 1.0;
        Widget face = BriscolaCardView(card: back ? null : card, width: width);
        if (flipFrom) face = Transform(alignment: Alignment.center, transform: Matrix4.diagonal3Values(sx, 1, 1), child: face);
        if (dim) face = Opacity(opacity: .75, child: face);
        return Transform.translate(
          offset: from * (1 - t),
          child: Transform.rotate(
            angle: angle * (1 - t),
            child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: face),
          ),
        );
      },
    );
  }
}

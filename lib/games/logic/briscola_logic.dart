import 'dart:math';

/// Carta italiana da 40: seme 0 coppe, 1 denari, 2 spade, 3 bastoni;
/// valore 1 asso, 2-7, 8 fante, 9 cavallo, 10 re.
class BCard {
  final int suit;
  final int rank;
  const BCard(this.suit, this.rank);

  static const _points = {1: 11, 3: 10, 10: 4, 9: 3, 8: 2};
  static const _strength = {1: 10, 3: 9, 10: 8, 9: 7, 8: 6, 7: 5, 6: 4, 5: 3, 4: 2, 2: 1};

  int get points => _points[rank] ?? 0;
  int get strength => _strength[rank]!;
}

/// Briscola a due: 3 carte in mano, la carta scoperta sotto il mazzo fissa la
/// briscola (e si pesca per ultima). Giocatore 0 = tu, 1 = telefono.
class BriscolaGame {
  final List<BCard> _deck; // si pesca dalla fine
  final BCard trumpCard;
  bool trumpTaken = false;
  final List<List<BCard>> hands = [[], []];
  final List<int> score = [0, 0];
  final List<BCard?> table = [null, null];
  int leader;

  BriscolaGame._(this._deck, this.trumpCard, this.leader);

  factory BriscolaGame.deal(Random rnd, {int leader = 0}) {
    final deck = [for (var s = 0; s < 4; s++) for (var r = 1; r <= 10; r++) BCard(s, r)]..shuffle(rnd);
    final g = BriscolaGame._(deck, deck.removeAt(0), leader);
    for (var i = 0; i < 3; i++) {
      g._draw(leader);
      g._draw(1 - leader);
    }
    return g;
  }

  int get trump => trumpCard.suit;
  int get drawsLeft => _deck.length + (trumpTaken ? 0 : 1);

  /// Di chi tocca giocare.
  int get turn => table[leader] == null ? leader : 1 - leader;
  bool get trickComplete => table[0] != null && table[1] != null;
  bool get isOver => hands[0].isEmpty && hands[1].isEmpty && drawsLeft == 0;

  /// 0 = tu, 1 = telefono, null = pareggio (60 a 60). Solo a partita finita.
  int? get winner => score[0] > 60 ? 0 : (score[1] > 60 ? 1 : null);

  void _draw(int p) {
    if (_deck.isNotEmpty) {
      hands[p].add(_deck.removeLast());
    } else if (!trumpTaken) {
      hands[p].add(trumpCard);
      trumpTaken = true;
    }
  }

  void play(int player, int index) {
    assert(turn == player && table[player] == null);
    table[player] = hands[player].removeAt(index);
  }

  /// Chi prende (rispondendo) la mano: stesso seme e più alta, oppure briscola.
  static bool followerWins(BCard lead, BCard reply, int trump) {
    if (reply.suit == lead.suit) return reply.strength > lead.strength;
    return reply.suit == trump;
  }

  /// Assegna la mano, pesca (prima chi ha preso) e restituisce chi ha preso.
  int resolveTrick() {
    final lead = table[leader]!, reply = table[1 - leader]!;
    final w = followerWins(lead, reply, trump) ? 1 - leader : leader;
    score[w] += lead.points + reply.points;
    table[0] = table[1] = null;
    leader = w;
    _draw(w);
    _draw(1 - w);
    return w;
  }
}

/// Telefono: 0 = a caso; 1 = ragionato ma sbaglia una volta su quattro;
/// 2 = ragionato. Vede solo la sua mano e il tavolo.
class BriscolaAi {
  static int choose(BriscolaGame g, int me, int level, Random rnd) {
    final hand = g.hands[me];
    if (level == 0 || (level == 1 && rnd.nextInt(4) == 0)) return rnd.nextInt(hand.length);
    final trump = g.trump;
    // quanto "costa" giocare la carta: briscole e carichi si tengono
    int cost(BCard c) => (c.suit == trump ? 100 : 0) + c.points * 3 + c.strength;
    int cheapest(Iterable<int> idx) => idx.reduce((a, b) => cost(hand[a]) <= cost(hand[b]) ? a : b);
    final all = [for (var i = 0; i < hand.length; i++) i];
    final lead = g.table[1 - me];
    if (lead == null) return cheapest(all);
    final wins = all.where((i) => BriscolaGame.followerWins(lead, hand[i], trump)).toList();
    if (wins.isNotEmpty) {
      final w = cheapest(wins);
      final c = hand[w];
      final worth = c.suit != trump
          ? true
          : (lead.points == 0 ? false : (c.points >= 10 ? lead.points >= 10 : lead.points >= 3));
      if (worth && (lead.points > 0 || c.points == 0)) return w;
    }
    return cheapest(all);
  }
}

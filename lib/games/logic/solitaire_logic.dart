import 'dart:math';

class SCard {
  final int rank; // 1 = asso ... 13 = re
  final int suit; // 0 ♠, 1 ♥, 2 ♦, 3 ♣
  bool faceUp;
  SCard(this.rank, this.suit, {this.faceUp = false});

  bool get red => suit == 1 || suit == 2;
  String get rankLabel => switch (rank) { 1 => 'A', 11 => 'J', 12 => 'Q', 13 => 'K', _ => '$rank' };
  static const suits = ['♠', '♥', '♦', '♣'];
  String get suitLabel => suits[suit];
}

/// Dove si trova la carta selezionata.
enum SolSource { waste, tableau, foundation }

class SolSelection {
  final SolSource source;
  final int index; // colonna o fondazione
  final int from; // posizione nella colonna (solo tableau)
  const SolSelection(this.source, this.index, [this.from = 0]);
}

/// Solitario Klondike, pesca una carta alla volta.
class SolitaireGame {
  final List<SCard> stock = [];
  final List<SCard> waste = [];
  final List<List<SCard>> foundations = List.generate(4, (_) => []); // per seme
  final List<List<SCard>> tableau = List.generate(7, (_) => []);
  int moves = 0;

  SolitaireGame(Random rand) {
    final deck = [
      for (var s = 0; s < 4; s++)
        for (var r = 1; r <= 13; r++) SCard(r, s),
    ]..shuffle(rand);
    var k = 0;
    for (var c = 0; c < 7; c++) {
      for (var i = 0; i <= c; i++) {
        final card = deck[k++];
        card.faceUp = i == c;
        tableau[c].add(card);
      }
    }
    stock.addAll(deck.sublist(k));
  }

  SolitaireGame._empty();

  /// Copia indipendente dello stato (per "annulla").
  SolitaireGame copy() {
    SCard dup(SCard c) => SCard(c.rank, c.suit, faceUp: c.faceUp);
    final g = SolitaireGame._empty()..moves = moves;
    g.stock.addAll(stock.map(dup));
    g.waste.addAll(waste.map(dup));
    for (var i = 0; i < 4; i++) {
      g.foundations[i].addAll(foundations[i].map(dup));
    }
    for (var i = 0; i < 7; i++) {
      g.tableau[i].addAll(tableau[i].map(dup));
    }
    return g;
  }

  bool get won => foundations.every((f) => f.length == 13);

  void drawStock() {
    if (stock.isNotEmpty) {
      final c = stock.removeLast()..faceUp = true;
      waste.add(c);
      moves++;
    } else if (waste.isNotEmpty) {
      while (waste.isNotEmpty) {
        stock.add(waste.removeLast()..faceUp = false);
      }
      moves++;
    }
  }

  List<SCard> cardsOf(SolSelection s) => switch (s.source) {
        SolSource.waste => waste.isEmpty ? [] : [waste.last],
        SolSource.foundation => foundations[s.index].isEmpty ? [] : [foundations[s.index].last],
        SolSource.tableau => tableau[s.index].sublist(s.from),
      };

  bool canToTableau(SCard moving, int col) {
    final pile = tableau[col];
    if (pile.isEmpty) return moving.rank == 13;
    final top = pile.last;
    return top.faceUp && top.red != moving.red && top.rank == moving.rank + 1;
  }

  bool canToFoundation(SCard c) => foundations[c.suit].length + 1 == c.rank;

  void _remove(SolSelection s) {
    switch (s.source) {
      case SolSource.waste:
        waste.removeLast();
      case SolSource.foundation:
        foundations[s.index].removeLast();
      case SolSource.tableau:
        tableau[s.index].removeRange(s.from, tableau[s.index].length);
        if (tableau[s.index].isNotEmpty) tableau[s.index].last.faceUp = true;
    }
  }

  bool moveToTableau(SolSelection s, int col) {
    final cards = cardsOf(s);
    if (cards.isEmpty) return false;
    if (s.source == SolSource.tableau && s.index == col) return false;
    if (!canToTableau(cards.first, col)) return false;
    _remove(s);
    tableau[col].addAll(cards);
    moves++;
    return true;
  }

  bool moveToFoundation(SolSelection s) {
    final cards = cardsOf(s);
    if (cards.length != 1) return false;
    final c = cards.first;
    if (s.source == SolSource.foundation || !canToFoundation(c)) return false;
    _remove(s);
    foundations[c.suit].add(c);
    moves++;
    return true;
  }
}

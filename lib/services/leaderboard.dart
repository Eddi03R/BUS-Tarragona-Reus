import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../games/game_art.dart';
import '../games/game_common.dart';
import 'analytics_service.dart';

/// Giochi e difficoltà delle sfide settimanali (a rotazione, uguali per tutti).
const challengeGames = [
  GameKind.ticTacToe,
  GameKind.battleship,
  GameKind.checkers,
  GameKind.chess,
  GameKind.briscola,
  GameKind.hangman,
  GameKind.mastermind,
  GameKind.minesweeper,
];

/// Una riga della classifica della settimana (un giocatore).
class WeekRow {
  final String uid, name;
  final int games, ch;
  final Map<String, int> wins;
  const WeekRow(this.uid, this.name, this.games, this.ch, this.wins);

  factory WeekRow.fromDoc(String uid, Map<String, dynamic> d) => WeekRow(
        uid,
        '${d['name'] ?? '?'}',
        (d['games'] as num?)?.toInt() ?? 0,
        (d['ch'] as num?)?.toInt() ?? 0,
        {for (final e in ((d['wins'] as Map?) ?? const {}).entries) '${e.key}': (e.value as num).toInt()},
      );
}

/// Mini profilo e classifiche settimanali. Niente login: il giocatore sceglie
/// un nome, Firebase gli dà un accesso anonimo. I conteggi vivono sul telefono
/// (GameStats) e vengono copiati su Firestore; la classifica si calcola leggendo
/// le righe della settimana.
class Leaderboard extends ChangeNotifier {
  Leaderboard._();
  static final Leaderboard instance = Leaderboard._();

  static const _nameKey = 'lb_name';
  String? name;

  Future<void> load() async {
    try {
      name = (await SharedPreferences.getInstance()).getString(_nameKey);
    } catch (_) {}
    notifyListeners();
  }

  // ── settimana e sfida ────────────────────────────────────────────────
  /// Numero della settimana (lunedì-domenica, in UTC; il 1/1/2024 era lunedì).
  static int weekOf(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2024)).inDays ~/ 7;

  /// Gioco e difficoltà della sfida: cicla 8 giochi, poi cambia difficoltà.
  static (GameKind, Difficulty) challengeFor(int week) =>
      (challengeGames[week % challengeGames.length],
          Difficulty.values[(week ~/ challengeGames.length) % Difficulty.values.length]);

  // ── conteggi sul telefono ────────────────────────────────────────────
  int wins(GameKind k) => GameStats.instance.value('wins_${k.name}');
  int losses(GameKind k) => GameStats.instance.value('losses_${k.name}');

  /// Chiamato da ResultBanner a ogni fine partita. `once` evita di contare due
  /// volte lo stesso risultato (la Parola del giorno si riapre già conclusa).
  Future<void> record(GameKind k, Difficulty d, ResultKind r, {String? once}) async {
    final s = GameStats.instance;
    if (once != null) {
      if (s.value('once_$once') == 1) return;
      await s.setValue('once_$once', 1);
    }
    final w = weekOf(DateTime.now());
    await s.setValue('wk${w}_p_${k.name}', 1);
    if (r == ResultKind.win) {
      await s.setValue('wins_${k.name}', wins(k) + 1);
      await s.setValue('wk${w}_w_${k.name}', s.value('wk${w}_w_${k.name}') + 1);
      if (challengeFor(w) == (k, d)) await s.setValue('wk${w}_ch', s.value('wk${w}_ch') + 1);
    } else if (r == ResultKind.lose) {
      await s.setValue('losses_${k.name}', losses(k) + 1);
    }
    sync();
  }

  // ── nome ─────────────────────────────────────────────────────────────
  static final _nameRe = RegExp(r'^[\p{L}0-9_.-]{3,16}$', unicode: true);
  static const _badWords = [
    'cazzo', 'merda', 'stronz', 'puttana', 'vaffanculo', 'minchia', 'coglion', 'frocio', 'bastard',
    'fuck', 'shit', 'bitch', 'cunt', 'asshole', 'nigg', 'faggot', 'whore', 'slut', 'hitler',
    'mierda', 'joder', 'cabron', 'gilipollas', 'pendejo', 'maricon', 'hijoputa',
    'collons', 'fillde', 'scheiss', 'fotze', 'hurensohn', 'wichser', 'schlampe',
  ];
  // parole corte: vietate solo se il nome è proprio quella (altrimenti "computare" ecc.)
  static const _badExact = ['puta', 'dick', 'figa', 'troia', 'cono', 'polla', 'arsch', 'nazi', 'rape', 'culo'];

  static bool isValidName(String n) => _nameRe.hasMatch(n);

  static bool isBadName(String n) {
    final s = n
        .toLowerCase()
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[àáâä]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's')
        .replaceAll(RegExp(r'[^a-z]'), '');
    return _badExact.contains(s) || _badWords.any(s.contains);
  }

  bool get available => AnalyticsService.instance.ready;

  Future<String> _uid() async {
    final a = FirebaseAuth.instance;
    return a.currentUser?.uid ?? (await a.signInAnonymously()).user!.uid;
  }

  /// Salva il nome. Restituisce null se ok, altrimenti "invalid", "bad",
  /// "taken" (già usato) oppure "offline".
  Future<String?> setName(String raw) async {
    final n = raw.trim();
    if (!isValidName(n)) return 'invalid';
    if (isBadName(n)) return 'bad';
    if (!available) return 'offline';
    try {
      final uid = await _uid();
      final db = FirebaseFirestore.instance;
      final old = name;
      // un nome per volta: le regole vietano di creare un nome già esistente
      final batch = db.batch();
      if (old != null && old.toLowerCase() != n.toLowerCase()) {
        batch.delete(db.doc('names/${old.toLowerCase()}'));
      }
      if (old == null || old.toLowerCase() != n.toLowerCase()) {
        batch.set(db.doc('names/${n.toLowerCase()}'), {'uid': uid});
      }
      // offline la scrittura resta in coda e non finisce mai: dopo 8 s si rinuncia
      await batch.commit().timeout(const Duration(seconds: 8));
      name = n;
      await (await SharedPreferences.getInstance()).setString(_nameKey, n);
      notifyListeners();
      sync();
      return null;
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied' ? 'taken' : 'offline';
    } catch (_) {
      return 'offline';
    }
  }

  // ── Firestore ────────────────────────────────────────────────────────
  Map<String, int> _perGame(int Function(GameKind) f) =>
      {for (final k in GameKind.values) if (f(k) > 0) k.name: f(k)};

  /// Copia i conteggi su Firestore (profilo + riga della settimana). Se manca
  /// la rete non fa nulla: si riprova alla partita successiva.
  Future<void> sync() async {
    final n = name;
    if (n == null || !available) return;
    try {
      final uid = await _uid();
      final db = FirebaseFirestore.instance;
      final s = GameStats.instance;
      final w = weekOf(DateTime.now());
      final weekWins = _perGame((k) => s.value('wk${w}_w_${k.name}'));
      // offline le scritture restano in coda e non finiscono: dopo 8 s si smette di aspettare
      await Future.wait([
        db.doc('players/$uid').set({
        'name': n,
        'trophies': s.recordCount,
        'wins': _perGame(wins),
        'losses': _perGame(losses),
        'plays': _perGame((k) => s.plays(k.name)),
        'updated': FieldValue.serverTimestamp(),
        }),
        db.doc('weeks/$w/players/$uid').set({
          'name': n,
          'games': GameKind.values.where((k) => s.value('wk${w}_p_${k.name}') == 1).length,
          'wins': weekWins,
          'ch': s.value('wk${w}_ch'),
        }),
      ]).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Leaderboard sync: $e');
    }
  }

  /// Le righe di una settimana, o null se la classifica non è raggiungibile.
  Future<List<WeekRow>?> fetchWeek(int week) async {
    if (!available) return null;
    try {
      await _uid();
      final snap = await FirebaseFirestore.instance.collection('weeks/$week/players').limit(300).get().timeout(const Duration(seconds: 8));
      return [for (final d in snap.docs) WeekRow.fromDoc(d.id, d.data())];
    } catch (e) {
      debugPrint('Leaderboard fetch: $e');
      return null;
    }
  }

  String? get myUid => available ? FirebaseAuth.instance.currentUser?.uid : null;
}

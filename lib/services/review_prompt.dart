import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Richiesta di recensione con la finestra nativa di Google Play, chiesta
/// con parsimonia: dopo qualche ricerca, a qualche giorno dal primo avvio e
/// al massimo una volta ogni 120 giorni. (Google limita comunque la frequenza.)
class ReviewPrompt {
  ReviewPrompt._();
  static final ReviewPrompt instance = ReviewPrompt._();

  static const _firstKey = 'review_first_launch';
  static const _countKey = 'review_search_count';
  static const _askedKey = 'review_last_ask';

  static const minSearches = 4;
  static const minDays = 3;
  static const retryDays = 120;

  bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> markLaunch() async {
    if (!_supported) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_firstKey)) {
        await prefs.setInt(_firstKey, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (_) {}
  }

  /// Da chiamare dopo che l'utente ha usato l'app con soddisfazione
  /// (es. al ritorno dai risultati di una ricerca).
  Future<void> maybeAsk() async {
    if (!_supported) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_countKey) ?? 0) + 1;
      await prefs.setInt(_countKey, count);
      final now = DateTime.now().millisecondsSinceEpoch;
      final first = prefs.getInt(_firstKey) ?? now;
      final last = prefs.getInt(_askedKey);
      const day = 24 * 60 * 60 * 1000;
      final ok = count >= minSearches &&
          now - first >= minDays * day &&
          (last == null || now - last >= retryDays * day);
      if (!ok) return;
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await prefs.setInt(_askedKey, now);
        await review.requestReview();
      }
    } catch (e) {
      debugPrint('Review prompt failed: $e');
    }
  }

  /// Apre la scheda dell'app su Google Play (voce "Valuta l'app").
  Future<void> openStore() async {
    try {
      await InAppReview.instance.openStoreListing();
    } catch (e) {
      debugPrint('Open store failed: $e');
    }
  }
}

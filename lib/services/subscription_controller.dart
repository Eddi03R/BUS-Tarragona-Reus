import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abbonamento al servizio bus, con data di acquisto e scadenza, persistito
/// localmente. Puramente informativo: serve solo a ricordare all'utente
/// quando scade, non è collegato a nessun sistema di biglietteria reale.
class SubscriptionController extends ChangeNotifier {
  SubscriptionController._();
  static final SubscriptionController instance = SubscriptionController._();

  static const _purchasePrefKey = 'subscription_purchase_date';
  static const _expiryPrefKey = 'subscription_expiry_date';

  DateTime? _purchaseDate;
  DateTime? _expiryDate;

  DateTime? get purchaseDate => _purchaseDate;
  DateTime? get expiryDate => _expiryDate;
  bool get hasSubscription => _expiryDate != null;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseMs = prefs.getInt(_purchasePrefKey);
      final expiryMs = prefs.getInt(_expiryPrefKey);
      if (purchaseMs != null) _purchaseDate = DateTime.fromMillisecondsSinceEpoch(purchaseMs);
      if (expiryMs != null) _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    } catch (_) {
      // Storage non disponibile: si resta senza abbonamento salvato.
    }
    notifyListeners();
  }

  Future<void> setSubscription({required DateTime purchaseDate, required DateTime expiryDate}) async {
    _purchaseDate = purchaseDate;
    _expiryDate = expiryDate;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_purchasePrefKey, purchaseDate.millisecondsSinceEpoch);
      await prefs.setInt(_expiryPrefKey, expiryDate.millisecondsSinceEpoch);
    } catch (_) {
      // Persistenza best-effort.
    }
  }

  Future<void> clear() async {
    _purchaseDate = null;
    _expiryDate = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_purchasePrefKey);
      await prefs.remove(_expiryPrefKey);
    } catch (_) {
      // Persistenza best-effort.
    }
  }

  /// Giorni rimanenti alla scadenza (negativo se già scaduto). Null se non
  /// è impostato nessun abbonamento.
  int? get daysRemaining {
    if (_expiryDate == null) return null;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final expiry = DateTime(_expiryDate!.year, _expiryDate!.month, _expiryDate!.day);
    return expiry.difference(today).inDays;
  }
}

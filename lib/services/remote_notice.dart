import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Avviso in un popup, deciso da Firebase Remote Config (senza rilasci).
/// Parametro `notice` (JSON), vuoto = nessun avviso:
/// {"id":"sciopero-20-nov","title":{"it":"..","en":".."},"text":{"it":"..","en":".."}}
/// title/text possono essere anche una semplice stringa. Cambiando `id` l'avviso
/// riappare anche a chi aveva chiuso il precedente.
class RemoteNotice {
  static const _param = 'notice';
  static const _seenKey = 'notice_seen_id';

  /// Estrae (id, titolo, testo) nella lingua data; null se non c'è un avviso valido.
  static ({String id, String title, String text})? parse(String raw, String lang) {
    try {
      final m = jsonDecode(raw);
      if (m is! Map) return null;
      String pick(Object? v) {
        if (v is Map) {
          final s = v[lang] ?? v['en'] ?? v['it'] ?? (v.values.isEmpty ? null : v.values.first);
          return s?.toString() ?? '';
        }
        return v?.toString() ?? '';
      }
      final title = pick(m['title']), text = pick(m['text']);
      if (title.isEmpty && text.isEmpty) return null;
      return (id: m['id']?.toString() ?? '$title|$text', title: title, text: text);
    } catch (_) {
      return null;
    }
  }

  static Future<void> maybeShow(BuildContext context) async {
    if (!AnalyticsService.instance.ready) return;
    String raw;
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1)));
      await rc.setDefaults({_param: ''});
      await rc.fetchAndActivate();
      raw = rc.getString(_param);
    } catch (e) {
      debugPrint('Remote Config failed: $e');
      return;
    }
    if (raw.isEmpty || !context.mounted) return;
    final n = parse(raw, Localizations.localeOf(context).languageCode);
    if (n == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_seenKey) == n.id || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: n.title.isEmpty ? null : Text(n.title),
        content: SingleChildScrollView(child: Text(n.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx)!.noticeClose),
          ),
        ],
      ),
    );
    await prefs.setString(_seenKey, n.id);
  }
}

import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_version.dart';

/// "Novità" della versione, in un avviso che compare una volta sola, alla prima
/// apertura dopo l'aggiornamento. I testi sono nell'app (nessun server):
/// così valgono per quella versione e per nessun'altra. Chi ha una versione
/// più vecchia non ha questo codice; chi ne ha una più nuova non trova la voce
/// della sua versione (o l'ha già vista).
///
/// **A ogni rilascio con un nuovo numero di versione (x.y.z) si aggiunge qui la
/// sua voce**; senza voce non compare nulla.
class WhatsNew {
  static const _seenKey = 'whatsnew_seen_version';

  /// Novità per versione (senza numero di build): lingua → punti elenco.
  static const Map<String, Map<String, List<String>>> entries = {
    '1.0.2': {
      'it': [
        'Tre giochi nuovi: Mastermind, Impiccato e Travasa i colori.',
        'Una canzoncina diversa per ogni gioco (accendi "Suoni dei giochi" in Impostazioni).',
        'Bus e minibus: 20 livelli per ogni difficoltà.',
        'Connessioni: si vedono le categorie e le parole sbagliate diventano rosse.',
        'Snake è più fluido.',
        'Classifiche e sfida settimanale: tocca la coppa nei giochi, scegli un nome e confrontati con gli altri giocatori.',
      ],
      'en': [
        'Three new games: Mastermind, Hangman and Water Sort.',
        'A different tune for every game (turn on "Game sounds" in Settings).',
        'Buses and minibuses: 20 levels for every difficulty.',
        'Connections: categories are shown and wrong words turn red.',
        'Snake is smoother.',
        'Rankings and weekly challenge: tap the trophy in the games, pick a name and compare yourself with other players.',
      ],
      'es': [
        'Tres juegos nuevos: Mastermind, Ahorcado y Ordena los colores.',
        'Una melodía distinta para cada juego (activa "Sonidos de los juegos" en Ajustes).',
        'Autobuses y minibuses: 20 niveles por dificultad.',
        'Conexiones: se ven las categorías y las palabras erróneas se ponen en rojo.',
        'Snake es más fluido.',
        'Clasificaciones y reto semanal: toca el trofeo en los juegos, elige un nombre y compárate con otros jugadores.',
      ],
      'ca': [
        'Tres jocs nous: Mastermind, Penjat i Ordena els colors.',
        'Una cançó diferent per a cada joc (activa "Sons dels jocs" a Ajustos).',
        'Autobusos i minibusos: 20 nivells per dificultat.',
        'Connexions: es veuen les categories i les paraules errònies es posen en vermell.',
        'Snake és més fluid.',
        'Classificacions i repte setmanal: toca el trofeu als jocs, tria un nom i compara\'t amb altres jugadors.',
      ],
      'de': [
        'Drei neue Spiele: Mastermind, Galgenraten und Farben sortieren.',
        'Eine andere Melodie für jedes Spiel ("Spielsounds" in den Einstellungen einschalten).',
        'Busse und Kleinbusse: 20 Level pro Schwierigkeit.',
        'Verbindungen: Kategorien werden angezeigt, falsche Wörter werden rot.',
        'Snake läuft flüssiger.',
        'Ranglisten und Wochen-Challenge: Tippe in den Spielen auf den Pokal, wähle einen Namen und vergleiche dich mit anderen Spielern.',
      ],
    },
  };

  /// Versione dell'app senza numero di build ("1.0.2").
  static String get version => RegExp(r'\d+\.\d+\.\d+').firstMatch(kAppVersion)?.group(0) ?? '';

  /// Punti elenco della versione [v] nella lingua [lang] (inglese se manca); null senza voce.
  static List<String>? linesFor(String v, String lang) {
    final e = entries[v];
    return e == null ? null : (e[lang] ?? e['en']);
  }

  /// Nuova installazione: niente novità (è tutto nuovo), ma si ricorda la versione.
  static Future<void> markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_seenKey, version);
    } catch (_) {}
  }

  /// Mostra le novità se questa versione ha una voce e non le ha ancora viste.
  static Future<void> maybeShow(BuildContext context) async {
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final l = AppLocalizations.of(context)!;
      final prefs = await SharedPreferences.getInstance();
      final v = version;
      if (v.isEmpty || prefs.getString(_seenKey) == v) return;
      // si ricorda subito: anche se l'app viene chiusa a metà, non si ripete
      await prefs.setString(_seenKey, v);
      final lines = linesFor(v, lang);
      if (lines == null || !context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.whatsNewTitle(v)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(line)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.noticeClose)),
          ],
        ),
      );
    } catch (_) {}
  }
}

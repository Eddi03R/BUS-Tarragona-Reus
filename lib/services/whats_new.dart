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

  /// Edizione delle novità: si alza quando si riscrive la voce di una versione
  /// già uscita senza cambiarne il numero, così l'avviso ricompare una volta.
  static const revision = 2;

  /// Novità per versione (senza numero di build): lingua → punti elenco.
  static const Map<String, Map<String, List<String>>> entries = {
    '1.0.2': {
      'it': [
        'Classifiche dei giochi: tocca l\'icona profilo, scegli un nome utente e confrontati con gli altri giocatori.',
        'Sfida della settimana: ogni settimana un gioco diverso, vince chi fa più vittorie.',
        'Il tuo profilo: livello, trofei e vinte/perse per ogni gioco.',
        'Aiuto con pubblicità in tutti i giochi: un suggerimento, una vita in più o un annulla (gratis con l\'abbonamento "senza pubblicità").',
        'Tre giochi nuovi: Mastermind, Impiccato e Travasa i colori, con una canzoncina per ogni gioco.',
      ],
      'en': [
        'Game rankings: tap the profile icon, pick a username and compare yourself with other players.',
        'Challenge of the week: a different game every week, the most wins takes it.',
        'Your profile: level, trophies and wins/losses for every game.',
        'Ad-supported help in every game: a hint, an extra life or an undo (free with the "no ads" subscription).',
        'Three new games: Mastermind, Hangman and Water Sort, with a tune for every game.',
      ],
      'es': [
        'Clasificaciones de los juegos: toca el icono de perfil, elige un nombre de usuario y compárate con otros jugadores.',
        'Reto de la semana: cada semana un juego distinto, gana quien consigue más victorias.',
        'Tu perfil: nivel, trofeos y ganadas/perdidas de cada juego.',
        'Ayuda con anuncio en todos los juegos: una pista, una vida extra o deshacer (gratis con la suscripción "sin anuncios").',
        'Tres juegos nuevos: Mastermind, Ahorcado y Ordena los colores, con una melodía para cada juego.',
      ],
      'ca': [
        'Classificacions dels jocs: toca la icona de perfil, tria un nom d\'usuari i compara\'t amb altres jugadors.',
        'Repte de la setmana: cada setmana un joc diferent, guanya qui fa més victòries.',
        'El teu perfil: nivell, trofeus i guanyades/perdudes de cada joc.',
        'Ajuda amb anunci a tots els jocs: una pista, una vida extra o desfer (gratis amb la subscripció "sense anuncis").',
        'Tres jocs nous: Mastermind, Penjat i Ordena els colors, amb una cançó per a cada joc.',
      ],
      'de': [
        'Ranglisten der Spiele: Tippe auf das Profilsymbol, wähle einen Benutzernamen und vergleiche dich mit anderen Spielern.',
        'Challenge der Woche: jede Woche ein anderes Spiel, die meisten Siege gewinnen.',
        'Dein Profil: Level, Trophäen und Siege/Niederlagen für jedes Spiel.',
        'Hilfe mit Werbung in allen Spielen: ein Tipp, ein zusätzliches Leben oder Rückgängig (kostenlos mit dem Abo "ohne Werbung").',
        'Drei neue Spiele: Mastermind, Galgenraten und Farben sortieren, mit einer Melodie für jedes Spiel.',
      ],
    },
  };

  /// Cosa si ricorda come "già visto": versione + edizione ("1.0.2-2").
  static String get token => '$version-$revision';

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
      await prefs.setString(_seenKey, token);
    } catch (_) {}
  }

  /// Mostra le novità se questa versione ha una voce e non le ha ancora viste.
  static Future<void> maybeShow(BuildContext context) async {
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final l = AppLocalizations.of(context)!;
      final prefs = await SharedPreferences.getInstance();
      final v = version;
      if (v.isEmpty || prefs.getString(_seenKey) == token) return;
      // si ricorda subito: anche se l'app viene chiusa a metà, non si ripete
      await prefs.setString(_seenKey, token);
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

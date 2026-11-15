import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'ErasBus Tarragona'**
  String get appTitle;

  /// No description provided for @lineSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Linea e4 · Monbus'**
  String get lineSubtitle;

  /// No description provided for @mapTooltip.
  ///
  /// In it, this message translates to:
  /// **'Mappa fermate'**
  String get mapTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTooltip;

  /// No description provided for @departureLabel.
  ///
  /// In it, this message translates to:
  /// **'Partenza'**
  String get departureLabel;

  /// No description provided for @arrivalLabel.
  ///
  /// In it, this message translates to:
  /// **'Arrivo'**
  String get arrivalLabel;

  /// No description provided for @chooseDifferentStops.
  ///
  /// In it, this message translates to:
  /// **'Scegli due fermate diverse.'**
  String get chooseDifferentStops;

  /// No description provided for @inFavorites.
  ///
  /// In it, this message translates to:
  /// **'Nei preferiti'**
  String get inFavorites;

  /// No description provided for @saveAsFavorite.
  ///
  /// In it, this message translates to:
  /// **'Salva come preferita'**
  String get saveAsFavorite;

  /// No description provided for @whenTravel.
  ///
  /// In it, this message translates to:
  /// **'Quando vuoi viaggiare?'**
  String get whenTravel;

  /// No description provided for @departAfter.
  ///
  /// In it, this message translates to:
  /// **'Parto dopo le'**
  String get departAfter;

  /// No description provided for @arriveBy.
  ///
  /// In it, this message translates to:
  /// **'Arrivo entro le'**
  String get arriveBy;

  /// No description provided for @holidaySwitch.
  ///
  /// In it, this message translates to:
  /// **'Festivo (usa orario domenicale)'**
  String get holidaySwitch;

  /// No description provided for @nightServiceSwitch.
  ///
  /// In it, this message translates to:
  /// **'Servizio notturno'**
  String get nightServiceSwitch;

  /// No description provided for @calendarApplied.
  ///
  /// In it, this message translates to:
  /// **'Calendario applicato: {label}'**
  String calendarApplied(Object label);

  /// No description provided for @findBus.
  ///
  /// In it, this message translates to:
  /// **'Trova il bus'**
  String get findBus;

  /// No description provided for @goButton.
  ///
  /// In it, this message translates to:
  /// **'Vai'**
  String get goButton;

  /// No description provided for @selectStop.
  ///
  /// In it, this message translates to:
  /// **'Seleziona fermata'**
  String get selectStop;

  /// No description provided for @searchStopOrCity.
  ///
  /// In it, this message translates to:
  /// **'Cerca fermata o città…'**
  String get searchStopOrCity;

  /// No description provided for @noOtherBusToday.
  ///
  /// In it, this message translates to:
  /// **'Nessun altro bus oggi per questa tratta'**
  String get noOtherBusToday;

  /// No description provided for @nextBusArriving.
  ///
  /// In it, this message translates to:
  /// **'in arrivo'**
  String get nextBusArriving;

  /// No description provided for @nextBusInMinutes.
  ///
  /// In it, this message translates to:
  /// **'{minutes, plural, =1{tra 1 min} other{tra {minutes} min}}'**
  String nextBusInMinutes(num minutes);

  /// No description provided for @nextBusInHours.
  ///
  /// In it, this message translates to:
  /// **'tra {hours}h'**
  String nextBusInHours(Object hours);

  /// No description provided for @nextBusInHoursMinutes.
  ///
  /// In it, this message translates to:
  /// **'tra {hours}h {minutes} min'**
  String nextBusInHoursMinutes(Object hours, Object minutes);

  /// No description provided for @thenAt.
  ///
  /// In it, this message translates to:
  /// **'poi {time}'**
  String thenAt(Object time);

  /// No description provided for @subscriptionExpiredDays.
  ///
  /// In it, this message translates to:
  /// **'{days, plural, =1{Abbonamento scaduto da 1 giorno} other{Abbonamento scaduto da {days} giorni}}'**
  String subscriptionExpiredDays(num days);

  /// No description provided for @weatherRainingNow.
  ///
  /// In it, this message translates to:
  /// **'Sta piovendo a {place}, porta con te un ombrello! Ci sono {temp}°'**
  String weatherRainingNow(Object place, int temp);

  /// No description provided for @weatherMaybeRain.
  ///
  /// In it, this message translates to:
  /// **'Potrebbe piovere, meglio se porti un ombrello per sicurezza. Ci sono {temp}°'**
  String weatherMaybeRain(int temp);

  /// No description provided for @weatherMaybeRainIn.
  ///
  /// In it, this message translates to:
  /// **'Potrebbe piovere a {place}, meglio se porti un ombrello per sicurezza. Ci sono {temp}°'**
  String weatherMaybeRainIn(Object place, int temp);

  /// No description provided for @weatherSunny.
  ///
  /// In it, this message translates to:
  /// **'Goditi una splendida giornata di sole! Ci sono {temp}°'**
  String weatherSunny(int temp);

  /// No description provided for @subscriptionExpiresToday.
  ///
  /// In it, this message translates to:
  /// **'Abbonamento: scade oggi'**
  String get subscriptionExpiresToday;

  /// No description provided for @subscriptionExpiresInDays.
  ///
  /// In it, this message translates to:
  /// **'{days, plural, =1{Abbonamento: scade tra 1 giorno} other{Abbonamento: scade tra {days} giorni}}'**
  String subscriptionExpiresInDays(num days);

  /// No description provided for @lastBusBadge.
  ///
  /// In it, this message translates to:
  /// **'Ultimo bus verso questa destinazione'**
  String get lastBusBadge;

  /// No description provided for @tripInfoTitle.
  ///
  /// In it, this message translates to:
  /// **'Info sul viaggio'**
  String get tripInfoTitle;

  /// No description provided for @payCashOnly.
  ///
  /// In it, this message translates to:
  /// **'Biglietto a bordo: SOLO contanti, niente pagamento elettronico'**
  String get payCashOnly;

  /// No description provided for @recommendedBus.
  ///
  /// In it, this message translates to:
  /// **'Bus consigliato'**
  String get recommendedBus;

  /// No description provided for @noDirectTrip.
  ///
  /// In it, this message translates to:
  /// **'Nessuna corsa diretta'**
  String get noDirectTrip;

  /// No description provided for @noDirectTripMessage.
  ///
  /// In it, this message translates to:
  /// **'Non esiste una corsa diretta da \"{origin}\" a \"{destination}\" su questa linea. Prova a invertire partenza e arrivo.'**
  String noDirectTripMessage(Object origin, Object destination);

  /// No description provided for @noBusFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun bus trovato'**
  String get noBusFound;

  /// No description provided for @noBusFoundDepartMessage.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono più corse dopo questo orario per il calendario \"{calendar}\". Prova un altro orario o giorno.'**
  String noBusFoundDepartMessage(Object calendar);

  /// No description provided for @noBusFoundArriveMessage.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono corse che arrivano in tempo. Prova un orario limite più tardo o un altro giorno.'**
  String get noBusFoundArriveMessage;

  /// No description provided for @viewRouteOnMap.
  ///
  /// In it, this message translates to:
  /// **'Vedi il percorso sulla mappa'**
  String get viewRouteOnMap;

  /// No description provided for @tripDetailsTitle.
  ///
  /// In it, this message translates to:
  /// **'Dettagli viaggio'**
  String get tripDetailsTitle;

  /// No description provided for @shareTooltip.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get shareTooltip;

  /// No description provided for @fromLabel.
  ///
  /// In it, this message translates to:
  /// **'DA'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In it, this message translates to:
  /// **'A'**
  String get toLabel;

  /// No description provided for @direct.
  ///
  /// In it, this message translates to:
  /// **'Diretto'**
  String get direct;

  /// No description provided for @stopsCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 fermata} other{{count} fermate}}'**
  String stopsCount(num count);

  /// No description provided for @routeOnMap.
  ///
  /// In it, this message translates to:
  /// **'Percorso sulla mappa'**
  String get routeOnMap;

  /// No description provided for @stopsOfThisTrip.
  ///
  /// In it, this message translates to:
  /// **'Fermate di questa corsa'**
  String get stopsOfThisTrip;

  /// No description provided for @shareText.
  ///
  /// In it, this message translates to:
  /// **'Bus {origin} → {destination}\nParti alle {dep}, arrivi alle {arr} ({minutes} min) — {calendar}.'**
  String shareText(
    Object origin,
    Object destination,
    Object dep,
    Object arr,
    Object minutes,
    Object calendar,
  );

  /// No description provided for @lineStopsTitle.
  ///
  /// In it, this message translates to:
  /// **'Fermate della linea'**
  String get lineStopsTitle;

  /// No description provided for @calculatingRoute.
  ///
  /// In it, this message translates to:
  /// **'Calcolo percorso su strada…'**
  String get calculatingRoute;

  /// No description provided for @routeUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Percorso su strada non disponibile, mostro linee dirette'**
  String get routeUnavailable;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Chiaro, scuro o come da impostazioni del dispositivo.'**
  String get appearanceSubtitle;

  /// No description provided for @light.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get system;

  /// No description provided for @themeColor.
  ///
  /// In it, this message translates to:
  /// **'Colore del tema'**
  String get themeColor;

  /// No description provided for @themeColorSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli il colore principale dell\'app.'**
  String get themeColorSubtitle;

  /// No description provided for @colorGreen.
  ///
  /// In it, this message translates to:
  /// **'Verde Monbus'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In it, this message translates to:
  /// **'Blu'**
  String get colorBlue;

  /// No description provided for @colorIndigo.
  ///
  /// In it, this message translates to:
  /// **'Indaco'**
  String get colorIndigo;

  /// No description provided for @colorPurple.
  ///
  /// In it, this message translates to:
  /// **'Viola'**
  String get colorPurple;

  /// No description provided for @colorMagenta.
  ///
  /// In it, this message translates to:
  /// **'Magenta'**
  String get colorMagenta;

  /// No description provided for @colorCoral.
  ///
  /// In it, this message translates to:
  /// **'Rosso corallo'**
  String get colorCoral;

  /// No description provided for @colorOrange.
  ///
  /// In it, this message translates to:
  /// **'Arancione'**
  String get colorOrange;

  /// No description provided for @colorAmber.
  ///
  /// In it, this message translates to:
  /// **'Ambra'**
  String get colorAmber;

  /// No description provided for @colorTeal.
  ///
  /// In it, this message translates to:
  /// **'Turchese'**
  String get colorTeal;

  /// No description provided for @colorPetrol.
  ///
  /// In it, this message translates to:
  /// **'Blu petrolio'**
  String get colorPetrol;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli la lingua dell\'app o segui quella del dispositivo.'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In it, this message translates to:
  /// **'Automatica'**
  String get languageSystem;

  /// No description provided for @languageItalian.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageCatalan.
  ///
  /// In it, this message translates to:
  /// **'Català'**
  String get languageCatalan;

  /// No description provided for @languageSpanish.
  ///
  /// In it, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In it, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In it, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @subscription.
  ///
  /// In it, this message translates to:
  /// **'Abbonamento dei trasporti'**
  String get subscription;

  /// No description provided for @subscriptionSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Registra il tuo abbonamento per ricordarti quando scade. Solo un promemoria: non è collegato a nessun sistema di biglietteria.'**
  String get subscriptionSubtitle;

  /// No description provided for @purchaseDate.
  ///
  /// In it, this message translates to:
  /// **'Data di acquisto'**
  String get purchaseDate;

  /// No description provided for @duration.
  ///
  /// In it, this message translates to:
  /// **'Durata'**
  String get duration;

  /// No description provided for @oneMonth.
  ///
  /// In it, this message translates to:
  /// **'1 mese'**
  String get oneMonth;

  /// No description provided for @twoMonths.
  ///
  /// In it, this message translates to:
  /// **'2 mesi'**
  String get twoMonths;

  /// No description provided for @threeMonths.
  ///
  /// In it, this message translates to:
  /// **'3 mesi'**
  String get threeMonths;

  /// No description provided for @customDuration.
  ///
  /// In it, this message translates to:
  /// **'Personalizzata'**
  String get customDuration;

  /// No description provided for @expiryDate.
  ///
  /// In it, this message translates to:
  /// **'Data di scadenza'**
  String get expiryDate;

  /// No description provided for @chooseDate.
  ///
  /// In it, this message translates to:
  /// **'Scegli data'**
  String get chooseDate;

  /// No description provided for @saveSubscription.
  ///
  /// In it, this message translates to:
  /// **'Salva abbonamento'**
  String get saveSubscription;

  /// No description provided for @removeSubscription.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi abbonamento'**
  String get removeSubscription;

  /// No description provided for @chooseCustomExpiryWarning.
  ///
  /// In it, this message translates to:
  /// **'Scegli una data di scadenza personalizzata.'**
  String get chooseCustomExpiryWarning;

  /// No description provided for @expiredDays.
  ///
  /// In it, this message translates to:
  /// **'{days, plural, =1{Scaduto da 1 giorno} other{Scaduto da {days} giorni}}'**
  String expiredDays(num days);

  /// No description provided for @expiresToday.
  ///
  /// In it, this message translates to:
  /// **'Scade oggi'**
  String get expiresToday;

  /// No description provided for @expiresInDays.
  ///
  /// In it, this message translates to:
  /// **'{days, plural, =1{Scade tra 1 giorno} other{Scade tra {days} giorni}}'**
  String expiresInDays(num days);

  /// No description provided for @expiryLabel.
  ///
  /// In it, this message translates to:
  /// **'Scadenza: {date}'**
  String expiryLabel(Object date);

  /// No description provided for @calWeekday.
  ///
  /// In it, this message translates to:
  /// **'Feriale (Lun-Ven)'**
  String get calWeekday;

  /// No description provided for @calWeekdayAugust.
  ///
  /// In it, this message translates to:
  /// **'Feriale (agosto)'**
  String get calWeekdayAugust;

  /// No description provided for @calSaturday.
  ///
  /// In it, this message translates to:
  /// **'Sabato'**
  String get calSaturday;

  /// No description provided for @calSundayHoliday.
  ///
  /// In it, this message translates to:
  /// **'Domenica / festivo'**
  String get calSundayHoliday;

  /// No description provided for @calNight.
  ///
  /// In it, this message translates to:
  /// **'Servizio notturno'**
  String get calNight;

  /// No description provided for @directionReusTarragona.
  ///
  /// In it, this message translates to:
  /// **'Reus → Tarragona'**
  String get directionReusTarragona;

  /// No description provided for @directionTarragonaReus.
  ///
  /// In it, this message translates to:
  /// **'Tarragona → Reus'**
  String get directionTarragonaReus;

  /// No description provided for @minutesAbbrev.
  ///
  /// In it, this message translates to:
  /// **'{minutes} min'**
  String minutesAbbrev(Object minutes);

  /// No description provided for @loadError.
  ///
  /// In it, this message translates to:
  /// **'Errore nel caricamento degli orari:'**
  String get loadError;

  /// No description provided for @infoTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get infoTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In it, this message translates to:
  /// **'Informativa sulla privacy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyP1.
  ///
  /// In it, this message translates to:
  /// **'L\'app non raccoglie né trasmette dati personali a server esterni.'**
  String get privacyPolicyP1;

  /// No description provided for @privacyPolicyP2.
  ///
  /// In it, this message translates to:
  /// **'Le preferenze (tema, lingua) e i dati di abbonamento sono salvati solo sul tuo dispositivo tramite SharedPreferences e non vengono mai condivisi.'**
  String get privacyPolicyP2;

  /// No description provided for @privacyPolicyP3.
  ///
  /// In it, this message translates to:
  /// **'L\'app non utilizza analytics, cookie di profilazione o servizi di tracciamento di terze parti.'**
  String get privacyPolicyP3;

  /// No description provided for @privacyPolicyP4.
  ///
  /// In it, this message translates to:
  /// **'I dati di abbonamento vengono eliminati alla disinstallazione o tramite il pulsante «Rimuovi abbonamento» nelle impostazioni.'**
  String get privacyPolicyP4;

  /// No description provided for @privacyPolicyContact.
  ///
  /// In it, this message translates to:
  /// **'Per informazioni: lumestudio.app@gmail.com'**
  String get privacyPolicyContact;

  /// No description provided for @copyright.
  ///
  /// In it, this message translates to:
  /// **'© 2024–2026 Lume Labs App. Tutti i diritti riservati.'**
  String get copyright;

  /// No description provided for @nightServiceSalou.
  ///
  /// In it, this message translates to:
  /// **'Servizio notturno Salou'**
  String get nightServiceSalou;

  /// No description provided for @calNightSalou.
  ///
  /// In it, this message translates to:
  /// **'Notturno Salou'**
  String get calNightSalou;

  /// No description provided for @calNightNt3.
  ///
  /// In it, this message translates to:
  /// **'NT3 Tarragona-Salou'**
  String get calNightNt3;

  /// No description provided for @walkToPoiBanner.
  ///
  /// In it, this message translates to:
  /// **'{minutes, plural, =1{1 min a piedi} other{{minutes} min a piedi}}'**
  String walkToPoiBanner(int minutes);

  /// No description provided for @walkFromStop.
  ///
  /// In it, this message translates to:
  /// **'Dalla fermata: {stop}'**
  String walkFromStop(Object stop);

  /// No description provided for @poiSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'LUOGHI'**
  String get poiSectionTitle;

  /// No description provided for @stopsSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'FERMATE'**
  String get stopsSectionTitle;

  /// No description provided for @whereDoYouWantToGo.
  ///
  /// In it, this message translates to:
  /// **'Dove vuoi andare?'**
  String get whereDoYouWantToGo;

  /// No description provided for @titleDaylife.
  ///
  /// In it, this message translates to:
  /// **'Dove andiamo oggi?'**
  String get titleDaylife;

  /// No description provided for @titleNightlife.
  ///
  /// In it, this message translates to:
  /// **'Dove andiamo stanotte?'**
  String get titleNightlife;

  /// No description provided for @gpsDetecting.
  ///
  /// In it, this message translates to:
  /// **'Rilevamento posizione…'**
  String get gpsDetecting;

  /// No description provided for @change.
  ///
  /// In it, this message translates to:
  /// **'Cambia'**
  String get change;

  /// No description provided for @categoryUniversity.
  ///
  /// In it, this message translates to:
  /// **'Università'**
  String get categoryUniversity;

  /// No description provided for @categoryNightlife.
  ///
  /// In it, this message translates to:
  /// **'Vita notturna'**
  String get categoryNightlife;

  /// No description provided for @categoryAllStops.
  ///
  /// In it, this message translates to:
  /// **'Tutte le fermate'**
  String get categoryAllStops;

  /// No description provided for @gameSoundsTitle.
  ///
  /// In it, this message translates to:
  /// **'Suoni dei giochi'**
  String get gameSoundsTitle;

  /// No description provided for @gameSoundsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Effetti sonori nei minigiochi (vittoria, mosse, esplosioni…). Spenti di base.'**
  String get gameSoundsSubtitle;

  /// No description provided for @gameSoundsOff.
  ///
  /// In it, this message translates to:
  /// **'Disattiva i suoni'**
  String get gameSoundsOff;

  /// No description provided for @gameSoundsOn.
  ///
  /// In it, this message translates to:
  /// **'Attiva i suoni'**
  String get gameSoundsOn;

  /// No description provided for @tutorialSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get tutorialNext;

  /// No description provided for @tutorialDone.
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get tutorialDone;

  /// No description provided for @tutorialReview.
  ///
  /// In it, this message translates to:
  /// **'Rivedi il tutorial'**
  String get tutorialReview;

  /// No description provided for @tutorialReviewSub.
  ///
  /// In it, this message translates to:
  /// **'Una breve guida all\'uso dell\'app'**
  String get tutorialReviewSub;

  /// No description provided for @tutorial1Title.
  ///
  /// In it, this message translates to:
  /// **'Cerca la tua corsa'**
  String get tutorial1Title;

  /// No description provided for @tutorial1Text.
  ///
  /// In it, this message translates to:
  /// **'Qui trovi la partenza (di solito la rileva il GPS) e qui l\'arrivo: tocca per scegliere. Poi premi «Vai» per vedere i bus.'**
  String get tutorial1Text;

  /// No description provided for @tutorial2Title.
  ///
  /// In it, this message translates to:
  /// **'Corse rapide'**
  String get tutorial2Title;

  /// No description provided for @tutorial2Text.
  ///
  /// In it, this message translates to:
  /// **'Imposta casa e fermata abituale per partire con un tocco. Dopo una ricerca, tocca la stella ★ nel dettaglio della corsa per salvarla tra i preferiti.'**
  String get tutorial2Text;

  /// No description provided for @tutorial3Title.
  ///
  /// In it, this message translates to:
  /// **'Spezza l\'attesa'**
  String get tutorial3Title;

  /// No description provided for @tutorial3Text.
  ///
  /// In it, this message translates to:
  /// **'In attesa del bus? Qui trovi tanti minigiochi per passare il tempo.'**
  String get tutorial3Text;

  /// No description provided for @tutorial4Title.
  ///
  /// In it, this message translates to:
  /// **'Scrivici'**
  String get tutorial4Title;

  /// No description provided for @tutorial4Text.
  ///
  /// In it, this message translates to:
  /// **'Se vuoi richiedere una funzionalità o segnalare un bug, scrivici da Impostazioni → Informazioni → Contattaci.'**
  String get tutorial4Text;

  /// No description provided for @locationTitle.
  ///
  /// In it, this message translates to:
  /// **'Posizione'**
  String get locationTitle;

  /// No description provided for @locationSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Usa il GPS per trovare automaticamente la fermata più vicina.'**
  String get locationSubtitle;

  /// No description provided for @locationEnabled.
  ///
  /// In it, this message translates to:
  /// **'Rilevamento posizione GPS'**
  String get locationEnabled;

  /// No description provided for @locationEnabledSubtitle.
  ///
  /// In it, this message translates to:
  /// **'La posizione viene usata solo localmente, non viene mai trasmessa.'**
  String get locationEnabledSubtitle;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso posizione negato. Abilitalo dalle impostazioni del dispositivo.'**
  String get locationPermissionDenied;

  /// No description provided for @privacySection1Title.
  ///
  /// In it, this message translates to:
  /// **'Raccolta dati'**
  String get privacySection1Title;

  /// No description provided for @privacySection2Title.
  ///
  /// In it, this message translates to:
  /// **'Posizione GPS'**
  String get privacySection2Title;

  /// No description provided for @privacySection3Title.
  ///
  /// In it, this message translates to:
  /// **'Analytics e tracciamento'**
  String get privacySection3Title;

  /// No description provided for @privacySection4Title.
  ///
  /// In it, this message translates to:
  /// **'Mappe e servizi esterni'**
  String get privacySection4Title;

  /// No description provided for @privacyPolicyP2loc.
  ///
  /// In it, this message translates to:
  /// **'L\'app può richiedere l\'accesso alla posizione GPS per suggerire la fermata più vicina. La posizione viene elaborata solo sul dispositivo e non viene mai trasmessa. Il permesso è opzionale e può essere disattivato dalle Impostazioni.'**
  String get privacyPolicyP2loc;

  /// No description provided for @privacyPolicyP4osm.
  ///
  /// In it, this message translates to:
  /// **'Le tessere della mappa sono fornite da OpenStreetMap (tile.openstreetmap.org). Non vengono trasmessi dati personali in queste richieste. Il meteo è fornito da Open-Meteo (api.open-meteo.com): la richiesta contiene le coordinate della fermata e, come per ogni connessione, l\'indirizzo IP; non contiene altri dati personali.'**
  String get privacyPolicyP4osm;

  /// No description provided for @privacyViewOnline.
  ///
  /// In it, this message translates to:
  /// **'Vedi informativa completa online'**
  String get privacyViewOnline;

  /// No description provided for @recommendedStopTitle.
  ///
  /// In it, this message translates to:
  /// **'Fermata consigliata: {stop}'**
  String recommendedStopTitle(Object stop);

  /// No description provided for @recommendedStopNote.
  ///
  /// In it, this message translates to:
  /// **'Il bus si ferma qui anche se non compare nel percorso ufficiale. L\'orario è quello di Plaça Europa e può differire di qualche minuto.'**
  String get recommendedStopNote;

  /// No description provided for @nightMapsNote.
  ///
  /// In it, this message translates to:
  /// **'Le corse notturne non sono su Google Maps: il percorso mostrato potrebbe essere diverso.'**
  String get nightMapsNote;

  /// No description provided for @alightAt.
  ///
  /// In it, this message translates to:
  /// **'Scendi a:'**
  String get alightAt;

  /// No description provided for @alightHere.
  ///
  /// In it, this message translates to:
  /// **'Scendi qui'**
  String get alightHere;

  /// No description provided for @recommendedLabel.
  ///
  /// In it, this message translates to:
  /// **'consigliata'**
  String get recommendedLabel;

  /// No description provided for @supportTitle.
  ///
  /// In it, this message translates to:
  /// **'Supporta lo sviluppatore'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In it, this message translates to:
  /// **'L\'app è gratuita. Se ti è utile, puoi aiutarmi a mantenerla.'**
  String get supportSubtitle;

  /// No description provided for @watchAdButton.
  ///
  /// In it, this message translates to:
  /// **'Supporta lo sviluppatore guardando una pubblicità'**
  String get watchAdButton;

  /// No description provided for @adNotReady.
  ///
  /// In it, this message translates to:
  /// **'Pubblicità non ancora pronta, riprova tra qualche secondo.'**
  String get adNotReady;

  /// No description provided for @adThanks.
  ///
  /// In it, this message translates to:
  /// **'Grazie per il supporto! 💚'**
  String get adThanks;

  /// No description provided for @removeAdsTitle.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi la pubblicità'**
  String get removeAdsTitle;

  /// No description provided for @removeAdsMonthly.
  ///
  /// In it, this message translates to:
  /// **'{price} / mese'**
  String removeAdsMonthly(Object price);

  /// No description provided for @removeAdsYearly.
  ///
  /// In it, this message translates to:
  /// **'{price} / anno'**
  String removeAdsYearly(Object price);

  /// No description provided for @restorePurchases.
  ///
  /// In it, this message translates to:
  /// **'Ripristina acquisti'**
  String get restorePurchases;

  /// No description provided for @premiumActive.
  ///
  /// In it, this message translates to:
  /// **'Grazie! Hai la versione senza pubblicità.'**
  String get premiumActive;

  /// No description provided for @manageSubscription.
  ///
  /// In it, this message translates to:
  /// **'Gestisci abbonamento'**
  String get manageSubscription;

  /// No description provided for @adPrivacyOptions.
  ///
  /// In it, this message translates to:
  /// **'Opzioni privacy pubblicità'**
  String get adPrivacyOptions;

  /// No description provided for @supportLinkButton.
  ///
  /// In it, this message translates to:
  /// **'Supporta lo sviluppatore'**
  String get supportLinkButton;

  /// No description provided for @subscriptionUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Abbonamento non disponibile al momento.'**
  String get subscriptionUnavailable;

  /// No description provided for @privacySection5Title.
  ///
  /// In it, this message translates to:
  /// **'Pubblicità e acquisti'**
  String get privacySection5Title;

  /// No description provided for @privacyPolicyP5.
  ///
  /// In it, this message translates to:
  /// **'Su Android l\'app mostra pubblicità tramite Google AdMob, che può usare l\'identificativo pubblicitario del dispositivo e dati simili per mostrare annunci; in Europa l\'uso avviene solo dopo il tuo consenso, modificabile dalle Impostazioni. L\'abbonamento «senza pubblicità» è gestito da Google Play: l\'app non riceve né conserva i tuoi dati di pagamento. Anche il sito web mostra un banner pubblicitario tramite Google AdSense (in Europa solo dopo il tuo consenso).'**
  String get privacyPolicyP5;

  /// No description provided for @analyticsConsentText.
  ///
  /// In it, this message translates to:
  /// **'Usiamo statistiche anonime (Google Analytics) per migliorare l\'app. Le accetti?'**
  String get analyticsConsentText;

  /// No description provided for @analyticsAccept.
  ///
  /// In it, this message translates to:
  /// **'Accetta'**
  String get analyticsAccept;

  /// No description provided for @analyticsReject.
  ///
  /// In it, this message translates to:
  /// **'Rifiuta'**
  String get analyticsReject;

  /// No description provided for @analyticsSwitchTitle.
  ///
  /// In it, this message translates to:
  /// **'Statistiche anonime'**
  String get analyticsSwitchTitle;

  /// No description provided for @analyticsSwitchSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ci aiutano a migliorare l\'app (Google Analytics).'**
  String get analyticsSwitchSubtitle;

  /// No description provided for @privacySection6Title.
  ///
  /// In it, this message translates to:
  /// **'Statistiche e diagnostica'**
  String get privacySection6Title;

  /// No description provided for @privacyPolicyP6.
  ///
  /// In it, this message translates to:
  /// **'Con il tuo consenso usiamo Google Analytics (Firebase) per statistiche anonime di utilizzo, ad esempio quali ricerche vengono fatte e quali funzioni sono usate; puoi disattivarlo in qualsiasi momento dalle Impostazioni. Su Android usiamo anche Firebase Crashlytics, che invia rapporti tecnici sugli arresti dell\'app (tipo di dispositivo, versione di Android, errore) per correggerli. Non raccogliamo nome, e-mail o posizione.'**
  String get privacyPolicyP6;

  /// No description provided for @privacyAndStats.
  ///
  /// In it, this message translates to:
  /// **'Privacy e statistiche'**
  String get privacyAndStats;

  /// No description provided for @notSet.
  ///
  /// In it, this message translates to:
  /// **'Non impostato'**
  String get notSet;

  /// No description provided for @settingOn.
  ///
  /// In it, this message translates to:
  /// **'Attiva'**
  String get settingOn;

  /// No description provided for @settingOff.
  ///
  /// In it, this message translates to:
  /// **'Disattivata'**
  String get settingOff;

  /// No description provided for @specialThemes.
  ///
  /// In it, this message translates to:
  /// **'Temi speciali'**
  String get specialThemes;

  /// No description provided for @specialThemesNote.
  ///
  /// In it, this message translates to:
  /// **'Natale è sempre chiaro e Halloween sempre scuro: la modalità si blocca da sola.'**
  String get specialThemesNote;

  /// No description provided for @supportBannerShort.
  ///
  /// In it, this message translates to:
  /// **'Guarda un video o rimuovi la pubblicità'**
  String get supportBannerShort;

  /// No description provided for @watchAdTitle.
  ///
  /// In it, this message translates to:
  /// **'Guarda un video'**
  String get watchAdTitle;

  /// No description provided for @supportVideoNote.
  ///
  /// In it, this message translates to:
  /// **'Un modo per ringraziare: il video non rimuove la pubblicità.'**
  String get supportVideoNote;

  /// No description provided for @supportAdFreeNote.
  ///
  /// In it, this message translates to:
  /// **'Con l\'abbonamento il banner pubblicitario sparisce. Scegli mensile o annuale.'**
  String get supportAdFreeNote;

  /// No description provided for @subscriptionTerms.
  ///
  /// In it, this message translates to:
  /// **'L\'abbonamento si rinnova automaticamente fino a quando non lo annulli da Google Play.'**
  String get subscriptionTerms;

  /// No description provided for @bestValue.
  ///
  /// In it, this message translates to:
  /// **'Più conveniente'**
  String get bestValue;

  /// No description provided for @myPlacesTitle.
  ///
  /// In it, this message translates to:
  /// **'I miei posti'**
  String get myPlacesTitle;

  /// No description provided for @myPlacesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Imposta Casa e la tua fermata abituale (di solito vicino all\'università): avrai le corse con un tocco dalla home.'**
  String get myPlacesSubtitle;

  /// No description provided for @homeStopLabel.
  ///
  /// In it, this message translates to:
  /// **'Casa'**
  String get homeStopLabel;

  /// No description provided for @usualStopLabel.
  ///
  /// In it, this message translates to:
  /// **'Fermata abituale'**
  String get usualStopLabel;

  /// No description provided for @chooseStop.
  ///
  /// In it, this message translates to:
  /// **'Scegli una fermata'**
  String get chooseStop;

  /// No description provided for @clearPlace.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi'**
  String get clearPlace;

  /// No description provided for @backHome.
  ///
  /// In it, this message translates to:
  /// **'Torna a casa'**
  String get backHome;

  /// No description provided for @goToUsual.
  ///
  /// In it, this message translates to:
  /// **'Alla fermata abituale'**
  String get goToUsual;

  /// No description provided for @configureMyRoutes.
  ///
  /// In it, this message translates to:
  /// **'Configura le tue corse abituali'**
  String get configureMyRoutes;

  /// No description provided for @configureMyRoutesSub.
  ///
  /// In it, this message translates to:
  /// **'Imposta Casa e fermata abituale per avere le corse con un tocco'**
  String get configureMyRoutesSub;

  /// No description provided for @usefulInfoTitle.
  ///
  /// In it, this message translates to:
  /// **'Info utili'**
  String get usefulInfoTitle;

  /// No description provided for @infoSecUniversity.
  ///
  /// In it, this message translates to:
  /// **'Università'**
  String get infoSecUniversity;

  /// No description provided for @infoSecTransport.
  ///
  /// In it, this message translates to:
  /// **'Trasporti'**
  String get infoSecTransport;

  /// No description provided for @infoSecCities.
  ///
  /// In it, this message translates to:
  /// **'Città'**
  String get infoSecCities;

  /// No description provided for @infoDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'Link a siti esterni. Orari, prezzi e contatti possono cambiare: verifica sempre le fonti ufficiali.'**
  String get infoDisclaimer;

  /// No description provided for @linkUrv.
  ///
  /// In it, this message translates to:
  /// **'URV · Studenti internazionali'**
  String get linkUrv;

  /// No description provided for @linkUrvSub.
  ///
  /// In it, this message translates to:
  /// **'Accoglienza, corsi e documenti per chi arriva'**
  String get linkUrvSub;

  /// No description provided for @linkMonbus.
  ///
  /// In it, this message translates to:
  /// **'Monbus'**
  String get linkMonbus;

  /// No description provided for @linkMonbusSub.
  ///
  /// In it, this message translates to:
  /// **'Orari e informazioni ufficiali del servizio'**
  String get linkMonbusSub;

  /// No description provided for @linkBusplana.
  ///
  /// In it, this message translates to:
  /// **'Busplana'**
  String get linkBusplana;

  /// No description provided for @linkBusplanaSub.
  ///
  /// In it, this message translates to:
  /// **'Orari e informazioni dei bus Plana'**
  String get linkBusplanaSub;

  /// No description provided for @linkTarragona.
  ///
  /// In it, this message translates to:
  /// **'Ajuntament de Tarragona'**
  String get linkTarragona;

  /// No description provided for @linkReus.
  ///
  /// In it, this message translates to:
  /// **'Ajuntament de Reus'**
  String get linkReus;

  /// No description provided for @linkSalou.
  ///
  /// In it, this message translates to:
  /// **'Ajuntament de Salou'**
  String get linkSalou;

  /// No description provided for @linkTurisme.
  ///
  /// In it, this message translates to:
  /// **'Tarragona Turisme'**
  String get linkTurisme;

  /// No description provided for @arcadeButton.
  ///
  /// In it, this message translates to:
  /// **'Spezza l\'attesa'**
  String get arcadeButton;

  /// No description provided for @arcadeNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo!'**
  String get arcadeNew;

  /// No description provided for @arcadeMostPlayed.
  ///
  /// In it, this message translates to:
  /// **'Più giocati!'**
  String get arcadeMostPlayed;

  /// No description provided for @arcadeFavAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi ai preferiti'**
  String get arcadeFavAdd;

  /// No description provided for @arcadeFavRemove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dai preferiti'**
  String get arcadeFavRemove;

  /// No description provided for @arcadeRecords.
  ///
  /// In it, this message translates to:
  /// **'Record raggiunti'**
  String get arcadeRecords;

  /// No description provided for @arcadeTitle.
  ///
  /// In it, this message translates to:
  /// **'Spezza l\'attesa'**
  String get arcadeTitle;

  /// No description provided for @arcadeSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Gioca ai minigiochi di ErasBus Tarragona'**
  String get arcadeSubtitle;

  /// No description provided for @gameTicTacToe.
  ///
  /// In it, this message translates to:
  /// **'Tris'**
  String get gameTicTacToe;

  /// No description provided for @gameBattleship.
  ///
  /// In it, this message translates to:
  /// **'Battaglia navale'**
  String get gameBattleship;

  /// No description provided for @gameSudoku.
  ///
  /// In it, this message translates to:
  /// **'Sudoku'**
  String get gameSudoku;

  /// No description provided for @gameMaze.
  ///
  /// In it, this message translates to:
  /// **'Labirinto'**
  String get gameMaze;

  /// No description provided for @gameBusJam.
  ///
  /// In it, this message translates to:
  /// **'Bus e minibus'**
  String get gameBusJam;

  /// No description provided for @gameTicTacToeDesc.
  ///
  /// In it, this message translates to:
  /// **'Sfida il telefono'**
  String get gameTicTacToeDesc;

  /// No description provided for @gameBattleshipDesc.
  ///
  /// In it, this message translates to:
  /// **'Affonda la flotta nemica'**
  String get gameBattleshipDesc;

  /// No description provided for @gameSudokuDesc.
  ///
  /// In it, this message translates to:
  /// **'Completa la griglia'**
  String get gameSudokuDesc;

  /// No description provided for @gameMazeDesc.
  ///
  /// In it, this message translates to:
  /// **'Trova l\'uscita'**
  String get gameMazeDesc;

  /// No description provided for @gameBusJamDesc.
  ///
  /// In it, this message translates to:
  /// **'Fai uscire il bus rosso'**
  String get gameBusJamDesc;

  /// No description provided for @difficultyEasy.
  ///
  /// In it, this message translates to:
  /// **'Facile'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In it, this message translates to:
  /// **'Medio'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In it, this message translates to:
  /// **'Difficile'**
  String get difficultyHard;

  /// No description provided for @gameNew.
  ///
  /// In it, this message translates to:
  /// **'Nuova partita'**
  String get gameNew;

  /// No description provided for @gameYouWin.
  ///
  /// In it, this message translates to:
  /// **'Hai vinto!'**
  String get gameYouWin;

  /// No description provided for @gameYouLose.
  ///
  /// In it, this message translates to:
  /// **'Hai perso'**
  String get gameYouLose;

  /// No description provided for @gameDraw.
  ///
  /// In it, this message translates to:
  /// **'Pareggio'**
  String get gameDraw;

  /// No description provided for @gameYourTurn.
  ///
  /// In it, this message translates to:
  /// **'Tocca a te'**
  String get gameYourTurn;

  /// No description provided for @gameThinking.
  ///
  /// In it, this message translates to:
  /// **'Il telefono pensa…'**
  String get gameThinking;

  /// No description provided for @gameNoRecord.
  ///
  /// In it, this message translates to:
  /// **'Nessun record'**
  String get gameNoRecord;

  /// No description provided for @gameSolved.
  ///
  /// In it, this message translates to:
  /// **'Risolto!'**
  String get gameSolved;

  /// No description provided for @gameClear.
  ///
  /// In it, this message translates to:
  /// **'Cancella'**
  String get gameClear;

  /// No description provided for @gameRestart.
  ///
  /// In it, this message translates to:
  /// **'Ricomincia'**
  String get gameRestart;

  /// No description provided for @gameNextLevel.
  ///
  /// In it, this message translates to:
  /// **'Livello successivo'**
  String get gameNextLevel;

  /// No description provided for @gameLevelDone.
  ///
  /// In it, this message translates to:
  /// **'Livello completato!'**
  String get gameLevelDone;

  /// No description provided for @gameMazeHint.
  ///
  /// In it, this message translates to:
  /// **'Scorri sul labirinto o usa le frecce fino alla bandiera'**
  String get gameMazeHint;

  /// No description provided for @gameBusJamHint.
  ///
  /// In it, this message translates to:
  /// **'Trascina i mezzi per liberare la strada al bus rosso'**
  String get gameBusJamHint;

  /// No description provided for @gameBattleshipHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca il mare nemico per sparare'**
  String get gameBattleshipHint;

  /// No description provided for @gameEnemySea.
  ///
  /// In it, this message translates to:
  /// **'Mare nemico'**
  String get gameEnemySea;

  /// No description provided for @gameYourSea.
  ///
  /// In it, this message translates to:
  /// **'Il tuo mare'**
  String get gameYourSea;

  /// No description provided for @gameHit.
  ///
  /// In it, this message translates to:
  /// **'Colpito!'**
  String get gameHit;

  /// No description provided for @gameMiss.
  ///
  /// In it, this message translates to:
  /// **'Acqua'**
  String get gameMiss;

  /// No description provided for @gameSunk.
  ///
  /// In it, this message translates to:
  /// **'Affondata!'**
  String get gameSunk;

  /// No description provided for @gameBest.
  ///
  /// In it, this message translates to:
  /// **'Record: {value}'**
  String gameBest(Object value);

  /// No description provided for @gameBestMoves.
  ///
  /// In it, this message translates to:
  /// **'Record: {n} mosse'**
  String gameBestMoves(int n);

  /// No description provided for @gameMoves.
  ///
  /// In it, this message translates to:
  /// **'Mosse: {n}'**
  String gameMoves(int n);

  /// No description provided for @gameLevel.
  ///
  /// In it, this message translates to:
  /// **'Livello {n}'**
  String gameLevel(int n);

  /// No description provided for @gamePlaceShips.
  ///
  /// In it, this message translates to:
  /// **'Posiziona le tue navi: tocca la griglia per piazzare la prossima nave. Tocca una nave per rimuoverla.'**
  String get gamePlaceShips;

  /// No description provided for @gameRotate.
  ///
  /// In it, this message translates to:
  /// **'Ruota'**
  String get gameRotate;

  /// No description provided for @gameHorizontal.
  ///
  /// In it, this message translates to:
  /// **'Orizzontale'**
  String get gameHorizontal;

  /// No description provided for @gameVertical.
  ///
  /// In it, this message translates to:
  /// **'Verticale'**
  String get gameVertical;

  /// No description provided for @gameRandom.
  ///
  /// In it, this message translates to:
  /// **'Casuale'**
  String get gameRandom;

  /// No description provided for @gameStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get gameStart;

  /// No description provided for @gameShipNoFit.
  ///
  /// In it, this message translates to:
  /// **'Qui la nave non ci sta'**
  String get gameShipNoFit;

  /// No description provided for @gameFire.
  ///
  /// In it, this message translates to:
  /// **'Tocca a te: spara!'**
  String get gameFire;

  /// No description provided for @gameEnemyTurn.
  ///
  /// In it, this message translates to:
  /// **'Turno dell\'avversario…'**
  String get gameEnemyTurn;

  /// No description provided for @gameYou.
  ///
  /// In it, this message translates to:
  /// **'Tu'**
  String get gameYou;

  /// No description provided for @gameOpponent.
  ///
  /// In it, this message translates to:
  /// **'Avversario'**
  String get gameOpponent;

  /// No description provided for @widgetInPrefix.
  ///
  /// In it, this message translates to:
  /// **'tra'**
  String get widgetInPrefix;

  /// No description provided for @widgetMinSuffix.
  ///
  /// In it, this message translates to:
  /// **'min'**
  String get widgetMinSuffix;

  /// No description provided for @widgetNoTrips.
  ///
  /// In it, this message translates to:
  /// **'Nessuna corsa prevista'**
  String get widgetNoTrips;

  /// No description provided for @widgetHint.
  ///
  /// In it, this message translates to:
  /// **'Puoi aggiungere il widget «ErasBus» alla schermata Home del telefono: tieni premuto sullo sfondo → Widget. Mostra le prossime corse per Casa e fermata abituale.'**
  String get widgetHint;

  /// No description provided for @contactTitle.
  ///
  /// In it, this message translates to:
  /// **'Contattaci'**
  String get contactTitle;

  /// No description provided for @contactText.
  ///
  /// In it, this message translates to:
  /// **'Hai una richiesta per una nuova funzione o vuoi segnalare un bug? Scrivici una mail:'**
  String get contactText;

  /// No description provided for @rateApp.
  ///
  /// In it, this message translates to:
  /// **'Valuta l\'app'**
  String get rateApp;

  /// No description provided for @shipCarrier.
  ///
  /// In it, this message translates to:
  /// **'Portaerei (4)'**
  String get shipCarrier;

  /// No description provided for @shipDestroyer.
  ///
  /// In it, this message translates to:
  /// **'Cacciatorpediniere (3)'**
  String get shipDestroyer;

  /// No description provided for @shipPatrol.
  ///
  /// In it, this message translates to:
  /// **'Motovedetta (2)'**
  String get shipPatrol;

  /// No description provided for @gamePlay.
  ///
  /// In it, this message translates to:
  /// **'Gioca'**
  String get gamePlay;

  /// No description provided for @gameDifficulty.
  ///
  /// In it, this message translates to:
  /// **'Difficoltà'**
  String get gameDifficulty;

  /// No description provided for @gameTicTacToeHow.
  ///
  /// In it, this message translates to:
  /// **'Allinea tre simboli in riga, colonna o diagonale prima del telefono. Tu giochi con la X e inizi per primo.'**
  String get gameTicTacToeHow;

  /// No description provided for @gameBattleshipHow.
  ///
  /// In it, this message translates to:
  /// **'Posiziona la tua flotta (una portaerei, due cacciatorpediniere, due motovedette) e affonda quella nemica prima che il telefono affondi la tua. La difficoltà cambia quanto è astuto il telefono.'**
  String get gameBattleshipHow;

  /// No description provided for @gameSudokuHow.
  ///
  /// In it, this message translates to:
  /// **'Riempi la griglia con i numeri da 1 a 9 senza ripeterli su righe, colonne e riquadri 3×3. Più è difficile, meno numeri trovi già scritti.'**
  String get gameSudokuHow;

  /// No description provided for @gameMazeHow.
  ///
  /// In it, this message translates to:
  /// **'Guida il bus dalla partenza alla bandiera. Il labirinto è sempre diverso e più è difficile, più è grande.'**
  String get gameMazeHow;

  /// No description provided for @gameBusJamHow.
  ///
  /// In it, this message translates to:
  /// **'Fai scorrere bus e minibus per liberare la strada e portare il bus rosso fuori dal parcheggio. Ogni difficoltà ha 10 livelli da sbloccare uno dopo l\'altro: meno mosse fai, meglio è.'**
  String get gameBusJamHow;

  /// No description provided for @gameBlocks.
  ///
  /// In it, this message translates to:
  /// **'Blocchi 1010'**
  String get gameBlocks;

  /// No description provided for @game2048.
  ///
  /// In it, this message translates to:
  /// **'2048'**
  String get game2048;

  /// No description provided for @gameMemory.
  ///
  /// In it, this message translates to:
  /// **'Memory'**
  String get gameMemory;

  /// No description provided for @gameWordle.
  ///
  /// In it, this message translates to:
  /// **'Parola del giorno'**
  String get gameWordle;

  /// No description provided for @gameFlow.
  ///
  /// In it, this message translates to:
  /// **'Collega i punti'**
  String get gameFlow;

  /// No description provided for @gameBlocksDesc.
  ///
  /// In it, this message translates to:
  /// **'Completa righe e colonne'**
  String get gameBlocksDesc;

  /// No description provided for @game2048Desc.
  ///
  /// In it, this message translates to:
  /// **'Unisci i numeri uguali'**
  String get game2048Desc;

  /// No description provided for @gameMemoryDesc.
  ///
  /// In it, this message translates to:
  /// **'Trova tutte le coppie'**
  String get gameMemoryDesc;

  /// No description provided for @gameWordleDesc.
  ///
  /// In it, this message translates to:
  /// **'Una nuova parola ogni giorno'**
  String get gameWordleDesc;

  /// No description provided for @gameFlowDesc.
  ///
  /// In it, this message translates to:
  /// **'Unisci i colori senza incroci'**
  String get gameFlowDesc;

  /// No description provided for @gameBlocksHow.
  ///
  /// In it, this message translates to:
  /// **'Trascina i pezzi sulla griglia 10×10: ogni riga o colonna completa si svuota. Più linee svuoti insieme, più punti fai. La partita finisce quando nessun pezzo entra più. Facile: pezzi piccoli; difficile: pezzi più grandi.'**
  String get gameBlocksHow;

  /// No description provided for @game2048How.
  ///
  /// In it, this message translates to:
  /// **'Scorri per spostare tutte le tessere: quelle con lo stesso numero si uniscono e raddoppiano. Arriva a 2048! Difficoltà: facile 5×5, medio 4×4, difficile 3×3.'**
  String get game2048How;

  /// No description provided for @gameMemoryHow.
  ///
  /// In it, this message translates to:
  /// **'Gira due carte alla volta e trova tutte le coppie nel minor tempo e con meno mosse. Facile: 6 coppie; medio: 8; difficile: 12.'**
  String get gameMemoryHow;

  /// No description provided for @gameWordleHow.
  ///
  /// In it, this message translates to:
  /// **'Indovina la parola di 5 lettere in 6 tentativi: scrivila e premi INVIO per vedere i colori. Verde: lettera giusta al posto giusto; giallo: lettera presente ma altrove; grigio: assente. La parola è la stessa per tutti e cambia ogni giorno, nella lingua dell\'app.'**
  String get gameWordleHow;

  /// No description provided for @gameArrows.
  ///
  /// In it, this message translates to:
  /// **'Frecce'**
  String get gameArrows;

  /// No description provided for @gameArrowsHow.
  ///
  /// In it, this message translates to:
  /// **'Tocca le frecce per spostarle fuori dal tabellone, ma attento: il loro percorso deve essere libero. Alcune frecce bloccano altre frecce, perciò scegli l\'ordine giusto per completare ogni livello. Hai 3 vite: ogni freccia bloccata che tocchi ne toglie una. Difficoltà: tabellone più grande e più frecce.'**
  String get gameArrowsHow;

  /// No description provided for @gameArrowsHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca una freccia che ha la strada libera'**
  String get gameArrowsHint;

  /// No description provided for @gameArrowsLeft.
  ///
  /// In it, this message translates to:
  /// **'Frecce: {n}'**
  String gameArrowsLeft(int n);

  /// No description provided for @wordleAttempts.
  ///
  /// In it, this message translates to:
  /// **'{n} tentativi'**
  String wordleAttempts(int n);

  /// No description provided for @gameFlowHow.
  ///
  /// In it, this message translates to:
  /// **'Unisci con una linea ogni coppia di punti dello stesso colore, senza incroci. C\'è una sola soluzione, e riempie tutti i riquadri. Difficoltà: più grande e più colori.'**
  String get gameFlowHow;

  /// No description provided for @gameBlocksHint.
  ///
  /// In it, this message translates to:
  /// **'Trascina un pezzo sulla griglia'**
  String get gameBlocksHint;

  /// No description provided for @game2048Hint.
  ///
  /// In it, this message translates to:
  /// **'Scorri in una direzione'**
  String get game2048Hint;

  /// No description provided for @gameMemoryHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca due carte per girarle'**
  String get gameMemoryHint;

  /// No description provided for @gameWordleHint.
  ///
  /// In it, this message translates to:
  /// **'Scrivi una parola di 5 lettere e premi INVIO'**
  String get gameWordleHint;

  /// No description provided for @gameFlowHint.
  ///
  /// In it, this message translates to:
  /// **'Trascina da un punto all\'altro dello stesso colore'**
  String get gameFlowHint;

  /// No description provided for @gameOver.
  ///
  /// In it, this message translates to:
  /// **'Partita finita'**
  String get gameOver;

  /// No description provided for @gamePerfect.
  ///
  /// In it, this message translates to:
  /// **'Perfetto!'**
  String get gamePerfect;

  /// No description provided for @wordleToday.
  ///
  /// In it, this message translates to:
  /// **'Parola di oggi'**
  String get wordleToday;

  /// No description provided for @wordleNotEnough.
  ///
  /// In it, this message translates to:
  /// **'Servono 5 lettere'**
  String get wordleNotEnough;

  /// No description provided for @wordleComeBack.
  ///
  /// In it, this message translates to:
  /// **'Torna domani per una nuova parola!'**
  String get wordleComeBack;

  /// No description provided for @wordleShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi il risultato'**
  String get wordleShare;

  /// No description provided for @wordlePractice.
  ///
  /// In it, this message translates to:
  /// **'Parola casuale'**
  String get wordlePractice;

  /// No description provided for @gameScore.
  ///
  /// In it, this message translates to:
  /// **'Punti: {n}'**
  String gameScore(int n);

  /// No description provided for @gameBestScore.
  ///
  /// In it, this message translates to:
  /// **'Record: {n}'**
  String gameBestScore(int n);

  /// No description provided for @wordleAnswer.
  ///
  /// In it, this message translates to:
  /// **'La parola era {word}'**
  String wordleAnswer(Object word);

  /// No description provided for @gameBackAgain.
  ///
  /// In it, this message translates to:
  /// **'Scorri di nuovo indietro per uscire'**
  String get gameBackAgain;

  /// No description provided for @wordlePressEnter.
  ///
  /// In it, this message translates to:
  /// **'Premi INVIO per confermare'**
  String get wordlePressEnter;

  /// No description provided for @wordleEnter.
  ///
  /// In it, this message translates to:
  /// **'INVIO'**
  String get wordleEnter;

  /// No description provided for @gameFlowFillAll.
  ///
  /// In it, this message translates to:
  /// **'Coppie unite! Ora riempi tutti i riquadri'**
  String get gameFlowFillAll;

  /// No description provided for @gameSnake.
  ///
  /// In it, this message translates to:
  /// **'Snake'**
  String get gameSnake;

  /// No description provided for @gameMines.
  ///
  /// In it, this message translates to:
  /// **'Campo minato'**
  String get gameMines;

  /// No description provided for @gameChess.
  ///
  /// In it, this message translates to:
  /// **'Scacchi'**
  String get gameChess;

  /// No description provided for @gameChessHow.
  ///
  /// In it, this message translates to:
  /// **'Gioca con i bianchi contro il telefono. Tocca un pezzo e poi la casella dove spostarlo: le mosse possibili si illuminano. Vale tutto: arrocco, presa al varco e promozione. Vince chi dà scacco matto. Più sale il livello, più il telefono pensa in anticipo.'**
  String get gameChessHow;

  /// No description provided for @gameCheckers.
  ///
  /// In it, this message translates to:
  /// **'Dama'**
  String get gameCheckers;

  /// No description provided for @gameCheckersHow.
  ///
  /// In it, this message translates to:
  /// **'Dama italiana: tu hai le pedine chiare, in basso. Le pedine vanno in avanti in diagonale e mangiano saltando un pezzo avversario; la presa è obbligatoria e va scelta quella che ne porta via di più. La pedina non può mangiare la dama. Arrivata in fondo, diventa dama. Vince chi blocca o mangia tutto.'**
  String get gameCheckersHow;

  /// No description provided for @gameCheck.
  ///
  /// In it, this message translates to:
  /// **'Scacco!'**
  String get gameCheck;

  /// No description provided for @gameStalemate.
  ///
  /// In it, this message translates to:
  /// **'Stallo: pareggio'**
  String get gameStalemate;

  /// No description provided for @gamePromote.
  ///
  /// In it, this message translates to:
  /// **'Scegli il pezzo'**
  String get gamePromote;

  /// No description provided for @gameMustCapture.
  ///
  /// In it, this message translates to:
  /// **'Presa obbligatoria!'**
  String get gameMustCapture;

  /// No description provided for @gameWins.
  ///
  /// In it, this message translates to:
  /// **'Vittorie: {n}'**
  String gameWins(int n);

  /// No description provided for @gameSolitaire.
  ///
  /// In it, this message translates to:
  /// **'Solitario'**
  String get gameSolitaire;

  /// No description provided for @gameSlide.
  ///
  /// In it, this message translates to:
  /// **'Puzzle scorrevole'**
  String get gameSlide;

  /// No description provided for @gameConnections.
  ///
  /// In it, this message translates to:
  /// **'Connessioni'**
  String get gameConnections;

  /// No description provided for @gameFlappy.
  ///
  /// In it, this message translates to:
  /// **'Bus volante'**
  String get gameFlappy;

  /// No description provided for @gameQuiz.
  ///
  /// In it, this message translates to:
  /// **'Quiz Catalunya'**
  String get gameQuiz;

  /// No description provided for @gameSnakeHow.
  ///
  /// In it, this message translates to:
  /// **'Guida il bus con uno swipe (o con le frecce) e mangia le fermate per allungarti, senza toccare te stesso. Facile: i bordi sono aperti; medio e difficile: i muri bloccano e si va più veloci.'**
  String get gameSnakeHow;

  /// No description provided for @gameMinesHow.
  ///
  /// In it, this message translates to:
  /// **'Scopri tutti i riquadri senza mine. I numeri dicono quante mine ci sono intorno. Tocco lungo (o modalità bandiera) per segnare una mina. Il primo tocco è sempre sicuro. Più è difficile, più mine ci sono.'**
  String get gameMinesHow;

  /// No description provided for @gameSolitaireHow.
  ///
  /// In it, this message translates to:
  /// **'Solitario Klondike: porta tutte le carte nelle quattro fondazioni, dall’asso al re, per seme. Sulle colonne si impilano carte a scalare di colore alternato. Tocca una carta e poi dove metterla; un secondo tocco la manda alla fondazione.'**
  String get gameSolitaireHow;

  /// No description provided for @gameSlideHow.
  ///
  /// In it, this message translates to:
  /// **'Fai scorrere le tessere per rimetterle in ordine da 1 in poi, con lo spazio vuoto in fondo. Facile 3×3, medio 4×4, difficile 5×5.'**
  String get gameSlideHow;

  /// No description provided for @gameConnectionsHow.
  ///
  /// In it, this message translates to:
  /// **'Ci sono 16 parole su Tarragona, Catalogna e Spagna: raggruppale in 4 gruppi da 4 con qualcosa in comune. Hai 4 errori a disposizione.'**
  String get gameConnectionsHow;

  /// No description provided for @gameFlappyHow.
  ///
  /// In it, this message translates to:
  /// **'Tocca lo schermo per far saltare il bus e passa tra i palazzi senza toccarli. Più è difficile, più vai veloce e più stretti sono i passaggi.'**
  String get gameFlappyHow;

  /// No description provided for @gameQuizHow.
  ///
  /// In it, this message translates to:
  /// **'10 domande mescolate su Tarragona, Santa Tecla, Spagna e Catalogna. Scegli la risposta giusta tra quattro.'**
  String get gameQuizHow;

  /// No description provided for @gameSnakeHint.
  ///
  /// In it, this message translates to:
  /// **'Scorri per partire e cambiare direzione'**
  String get gameSnakeHint;

  /// No description provided for @gameMinesHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca per scoprire, tocco lungo per la bandiera'**
  String get gameMinesHint;

  /// No description provided for @gameSolitaireHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca una carta e poi dove metterla'**
  String get gameSolitaireHint;

  /// No description provided for @gameSlideHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca una tessera accanto allo spazio vuoto'**
  String get gameSlideHint;

  /// No description provided for @gameConnectionsHint.
  ///
  /// In it, this message translates to:
  /// **'Seleziona 4 parole dello stesso gruppo'**
  String get gameConnectionsHint;

  /// No description provided for @gameFlappyHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca per saltare'**
  String get gameFlappyHint;

  /// No description provided for @gameMinesDig.
  ///
  /// In it, this message translates to:
  /// **'Scopri'**
  String get gameMinesDig;

  /// No description provided for @gameMinesFlag.
  ///
  /// In it, this message translates to:
  /// **'Bandiera'**
  String get gameMinesFlag;

  /// No description provided for @quizCatTarragona.
  ///
  /// In it, this message translates to:
  /// **'Tarragona'**
  String get quizCatTarragona;

  /// No description provided for @quizCatSantaTecla.
  ///
  /// In it, this message translates to:
  /// **'Santa Tecla'**
  String get quizCatSantaTecla;

  /// No description provided for @quizCatSpain.
  ///
  /// In it, this message translates to:
  /// **'Spagna'**
  String get quizCatSpain;

  /// No description provided for @quizCatCatalonia.
  ///
  /// In it, this message translates to:
  /// **'Catalogna'**
  String get quizCatCatalonia;

  /// No description provided for @quizScore.
  ///
  /// In it, this message translates to:
  /// **'{score} su {total}'**
  String quizScore(int score, int total);

  /// No description provided for @quizQuestionOf.
  ///
  /// In it, this message translates to:
  /// **'Domanda {n} di {total}'**
  String quizQuestionOf(int n, int total);

  /// No description provided for @quizNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get quizNext;

  /// No description provided for @quizFinish.
  ///
  /// In it, this message translates to:
  /// **'Vedi il risultato'**
  String get quizFinish;

  /// No description provided for @connMistakes.
  ///
  /// In it, this message translates to:
  /// **'Errori'**
  String get connMistakes;

  /// No description provided for @connSolvedCount.
  ///
  /// In it, this message translates to:
  /// **'Risolti: {n}'**
  String connSolvedCount(int n);

  /// No description provided for @connOneAway.
  ///
  /// In it, this message translates to:
  /// **'Ci sei quasi: ne manca una!'**
  String get connOneAway;

  /// No description provided for @connSubmit.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get connSubmit;

  /// No description provided for @connShuffle.
  ///
  /// In it, this message translates to:
  /// **'Mescola'**
  String get connShuffle;

  /// No description provided for @rewardedArrowsMessage.
  ///
  /// In it, this message translates to:
  /// **'Guarda una breve pubblicità per ottenere una vita e continuare il livello.'**
  String get rewardedArrowsMessage;

  /// No description provided for @rewardedArrowsButton.
  ///
  /// In it, this message translates to:
  /// **'Ottieni una vita'**
  String get rewardedArrowsButton;

  /// No description provided for @rewardedReviveTitle.
  ///
  /// In it, this message translates to:
  /// **'Vuoi recuperare la partita?'**
  String get rewardedReviveTitle;

  /// No description provided for @rewardedReviveMessage.
  ///
  /// In it, this message translates to:
  /// **'Guarda una breve pubblicità per continuare da dove eri rimasto, tenendo il punteggio.'**
  String get rewardedReviveMessage;

  /// No description provided for @rewardedBlocksMessage.
  ///
  /// In it, this message translates to:
  /// **'Guarda una breve pubblicità: il tavolo di gioco viene svuotato e tieni il punteggio.'**
  String get rewardedBlocksMessage;

  /// No description provided for @rewardedReviveButton.
  ///
  /// In it, this message translates to:
  /// **'Recupera la partita'**
  String get rewardedReviveButton;

  /// No description provided for @rewardedClearButton.
  ///
  /// In it, this message translates to:
  /// **'Svuota il tavolo e continua'**
  String get rewardedClearButton;

  /// No description provided for @rewardedSkipTitle.
  ///
  /// In it, this message translates to:
  /// **'Vuoi saltare il livello?'**
  String get rewardedSkipTitle;

  /// No description provided for @rewardedSkipMessage.
  ///
  /// In it, this message translates to:
  /// **'Guarda una breve pubblicità per saltare il livello.'**
  String get rewardedSkipMessage;

  /// No description provided for @rewardedSkipButton.
  ///
  /// In it, this message translates to:
  /// **'Salta il livello'**
  String get rewardedSkipButton;

  /// No description provided for @rewardedPeekTitle.
  ///
  /// In it, this message translates to:
  /// **'Vuoi vedere tutte le carte?'**
  String get rewardedPeekTitle;

  /// No description provided for @rewardedPeekMessage.
  ///
  /// In it, this message translates to:
  /// **'Guarda una breve pubblicità: le carte restano scoperte per qualche secondo.'**
  String get rewardedPeekMessage;

  /// No description provided for @rewardedPeekButton.
  ///
  /// In it, this message translates to:
  /// **'Mostra tutte le carte'**
  String get rewardedPeekButton;

  /// No description provided for @rewardedUndoTitle.
  ///
  /// In it, this message translates to:
  /// **'Vuoi annullare le ultime mosse?'**
  String get rewardedUndoTitle;

  /// No description provided for @rewardedUndoMessage.
  ///
  /// In it, this message translates to:
  /// **'Guarda una breve pubblicità per annullare le ultime 3 mosse.'**
  String get rewardedUndoMessage;

  /// No description provided for @rewardedUndoButton.
  ///
  /// In it, this message translates to:
  /// **'Annulla 3 mosse'**
  String get rewardedUndoButton;

  /// No description provided for @rewardedWatch.
  ///
  /// In it, this message translates to:
  /// **'Guarda la pubblicità'**
  String get rewardedWatch;

  /// No description provided for @rewardedContinue.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get rewardedContinue;

  /// No description provided for @rewardedNo.
  ///
  /// In it, this message translates to:
  /// **'No, grazie'**
  String get rewardedNo;

  /// No description provided for @rewardedFreeNote.
  ///
  /// In it, this message translates to:
  /// **'Puoi farlo subito, senza pubblicità.'**
  String get rewardedFreeNote;

  /// No description provided for @gameSkipped.
  ///
  /// In it, this message translates to:
  /// **'Livello saltato'**
  String get gameSkipped;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'de', 'en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

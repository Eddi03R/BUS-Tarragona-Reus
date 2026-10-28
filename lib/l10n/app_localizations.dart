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
    Locale('it')
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
  /// **'Ultimo bus della notte'**
  String get lastBusBadge;

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
  String shareText(Object origin, Object destination, Object dep, Object arr,
      Object minutes, Object calendar);

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
  /// **'Abbonamento'**
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
  /// **'Le tessere della mappa sono fornite da OpenStreetMap (tile.openstreetmap.org). Non vengono trasmessi dati personali in queste richieste.'**
  String get privacyPolicyP4osm;

  /// No description provided for @privacyViewOnline.
  ///
  /// In it, this message translates to:
  /// **'Vedi informativa completa online'**
  String get privacyViewOnline;
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
      'that was used.');
}

import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/schedule_repository.dart';
import 'screens/home_screen.dart';
import 'services/favorites_controller.dart';
import 'services/locale_controller.dart';
import 'services/subscription_controller.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BusApp());
}

class BusApp extends StatelessWidget {
  const BusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeController.instance, LocaleController.instance]),
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(ThemeController.instance.seedColor),
          darkTheme: AppTheme.dark(ThemeController.instance.seedColor),
          themeMode: ThemeController.instance.themeMode,
          // null = lascia che Flutter scelga in automatico dalla lingua del
          // browser/dispositivo tra quelle supportate; un valore non-null
          // (impostato dall'utente in Impostazioni) la forza esplicitamente.
          locale: LocaleController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            // Forza sempre il formato orario 24h, indipendentemente dal locale del dispositivo.
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
          home: const _AppLoader(),
        );
      },
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  late final Future<void> _loading;

  @override
  void initState() {
    super.initState();
    _loading = _bootstrap();
  }

  Future<void> _bootstrap() async {
    for (final locale in LocaleController.supportedLocales) {
      await initializeDateFormatting(locale.languageCode);
    }
    await Future.wait([
      ScheduleRepository.instance.load(),
      ThemeController.instance.load(),
      FavoritesController.instance.load(),
      SubscriptionController.instance.load(),
      LocaleController.instance.load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('${AppLocalizations.of(context)!.loadError} ${snapshot.error}')),
          );
        }
        return const HomeScreen();
      },
    );
  }
}

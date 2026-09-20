import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/schedule_repository.dart';
import 'screens/home_screen.dart';
import 'services/favorites_controller.dart';
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
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Reus ↔ Tarragona Bus',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(ThemeController.instance.seedColor),
          darkTheme: AppTheme.dark(ThemeController.instance.seedColor),
          themeMode: ThemeController.instance.themeMode,
          locale: const Locale('it', 'IT'),
          supportedLocales: const [Locale('it', 'IT')],
          localizationsDelegates: const [
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
    await initializeDateFormatting('it_IT');
    await Future.wait([
      ScheduleRepository.instance.load(),
      ThemeController.instance.load(),
      FavoritesController.instance.load(),
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
            body: Center(child: Text('Errore nel caricamento degli orari: ${snapshot.error}')),
          );
        }
        return const HomeScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:reus_tarragona_bus/services/subscription_controller.dart';
import 'package:reus_tarragona_bus/widgets/subscription_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget app(bool onlyExpired) => MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        supportedLocales: const [Locale('it')],
        locale: const Locale('it'),
        home: Scaffold(body: SubscriptionBanner(onlyExpired: onlyExpired)),
      );

  Future<void> setExpiry(int daysFromNow) => SubscriptionController.instance.setSubscription(
        purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(Duration(days: daysFromNow)),
      );

  testWidgets('Nightlife (onlyExpired): compare solo se scaduto davvero', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await setExpiry(-3);
    await tester.pumpWidget(app(true));
    expect(find.byIcon(Icons.confirmation_number_rounded), findsOneWidget);

    await setExpiry(5); // scade tra 5 giorni: non è scaduto
    await tester.pumpWidget(app(true));
    expect(find.byIcon(Icons.confirmation_number_rounded), findsNothing);

    await setExpiry(5); // Daylife continua a mostrare anche "scade tra X giorni"
    await tester.pumpWidget(app(false));
    expect(find.byIcon(Icons.confirmation_number_rounded), findsOneWidget);

    await SubscriptionController.instance.clear();
    await tester.pumpWidget(app(true));
    expect(find.byIcon(Icons.confirmation_number_rounded), findsNothing);
  });
}

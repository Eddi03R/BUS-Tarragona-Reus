import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Configurazione Firebase (progetto erasbus-tarragona-8a602).
/// Le chiavi API di Firebase identificano il progetto, non sono segreti.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return defaultTargetPlatform == TargetPlatform.iOS ? ios : android;
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9Gvq2jVIyduA06pgZC6bT9huBkbCqp3g',
    appId: '1:898469620532:ios:f0743f60cdac4f8ebf9361',
    messagingSenderId: '898469620532',
    projectId: 'erasbus-tarragona-8a602',
    storageBucket: 'erasbus-tarragona-8a602.firebasestorage.app',
    iosBundleId: 'app.lumelabs.bustarragona',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAISvGGMUK437IF71TGN6zQv7-CtFCwCKQ',
    authDomain: 'erasbus-tarragona-8a602.firebaseapp.com',
    projectId: 'erasbus-tarragona-8a602',
    storageBucket: 'erasbus-tarragona-8a602.firebasestorage.app',
    messagingSenderId: '898469620532',
    appId: '1:898469620532:web:5287a40deadfa81bbf9361',
    measurementId: 'G-50X69VW09T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC97c3EZ8dTUQtPt0ITEv241XQLbt8NIAk',
    appId: '1:898469620532:android:00f72dcef09ab965bf9361',
    messagingSenderId: '898469620532',
    projectId: 'erasbus-tarragona-8a602',
    storageBucket: 'erasbus-tarragona-8a602.firebasestorage.app',
  );
}

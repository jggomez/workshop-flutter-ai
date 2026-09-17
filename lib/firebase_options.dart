// File generated for Cancun DashBooth (FlutterConf LATAM 2026)
// Project ID: dashbooth-cancun-2026
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for Cancun DashBooth Web.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for Flutter Web: '
      '${defaultTargetPlatform.name}',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDfBY6KaMYdWPciTxup79rlkyovuYwMGms',
    appId: '1:1084274811775:web:8ceddb133a5eccc570704a',
    messagingSenderId: '1084274811775',
    projectId: 'dashbooth-cancun-2026',
    authDomain: 'dashbooth-cancun-2026.firebaseapp.com',
    storageBucket: 'dashbooth-cancun-2026-user-cards',
  );
}

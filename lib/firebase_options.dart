// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDMbtKwIm_0FE1FFTBsgnpwjuCb_5SCc_8',
    appId: '1:759923659185:web:853f796b606e4bd8fded90',
    messagingSenderId: '759923659185',
    projectId: 'aseepk-5e249',
    authDomain: 'aseepk-5e249.firebaseapp.com',
    storageBucket: 'aseepk-5e249.firebasestorage.app',
    measurementId: 'G-LVVENYVHZ8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfgSYM27pkP2mXxI2bthze1Bss8Ozx91c',
    appId: '1:759923659185:android:fc3afd97c3baf928fded90',
    messagingSenderId: '759923659185',
    projectId: 'aseepk-5e249',
    storageBucket: 'aseepk-5e249.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAUy30UYjHw29hteGYpK-nuATNZ49RmBak',
    appId: '1:759923659185:ios:b03ff54252e75ecbfded90',
    messagingSenderId: '759923659185',
    projectId: 'aseepk-5e249',
    storageBucket: 'aseepk-5e249.firebasestorage.app',
    iosBundleId: 'com.example.aseep',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAUy30UYjHw29hteGYpK-nuATNZ49RmBak',
    appId: '1:759923659185:ios:b03ff54252e75ecbfded90',
    messagingSenderId: '759923659185',
    projectId: 'aseepk-5e249',
    storageBucket: 'aseepk-5e249.firebasestorage.app',
    iosBundleId: 'com.example.aseep',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDMbtKwIm_0FE1FFTBsgnpwjuCb_5SCc_8',
    appId: '1:759923659185:web:50a2c6bc2512a9bbfded90',
    messagingSenderId: '759923659185',
    projectId: 'aseepk-5e249',
    authDomain: 'aseepk-5e249.firebaseapp.com',
    storageBucket: 'aseepk-5e249.firebasestorage.app',
    measurementId: 'G-NH5WT668D3',
  );

}
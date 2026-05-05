import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.linux:
        return desktop;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3zodrbFe5b-PGaqCSK9HwfGz9umrCwOc',
    appId: '1:804559797881:android:35e394c24f0aa53ee6dea8',
    messagingSenderId: '804559797881',
    projectId: 'peer-to-peer-f1f68',
    storageBucket: 'peer-to-peer-f1f68.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWaTZ4xsLyh9VrLKTH0Rj4vTycV6OBbbY',
    appId: '1:804559797881:ios:fdc95472f0aa2df4e6dea8',
    messagingSenderId: '804559797881',
    projectId: 'peer-to-peer-f1f68',
    storageBucket: 'peer-to-peer-f1f68.firebasestorage.app',
    iosBundleId: 'com.example.mobileApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWaTZ4xsLyh9VrLKTH0Rj4vTycV6OBbbY',
    appId: '1:804559797881:ios:fdc95472f0aa2df4e6dea8',
    messagingSenderId: '804559797881',
    projectId: 'peer-to-peer-f1f68',
    storageBucket: 'peer-to-peer-f1f68.firebasestorage.app',
    iosBundleId: 'com.example.mobileApp',
  );

  static const FirebaseOptions desktop = FirebaseOptions(
    apiKey: 'AIzaSyAfunRlXoBQP9u8z9pE-gmUcLo3kCBgVp8',
    appId: '1:804559797881:web:e3db7c670bf7847be6dea8',
    messagingSenderId: '804559797881',
    projectId: 'peer-to-peer-f1f68',
    storageBucket: 'peer-to-peer-f1f68.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfunRlXoBQP9u8z9pE-gmUcLo3kCBgVp8',
    appId: '1:804559797881:web:e3db7c670bf7847be6dea8',
    messagingSenderId: '804559797881',
    projectId: 'peer-to-peer-f1f68',
    authDomain: 'peer-to-peer-f1f68.firebaseapp.com',
    storageBucket: 'peer-to-peer-f1f68.firebasestorage.app',
    measurementId: 'G-F26N855C02',
  );

}
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
    apiKey: 'AIzaSyAnbl4liCC6xPKc4VeWvhHA8opKKCVjktY',
    appId: '1:635366621715:web:4de9877b560db8ebb7b5e6',
    messagingSenderId: '635366621715',
    projectId: 'plan-it-app-81de0',
    authDomain: 'plan-it-app-81de0.firebaseapp.com',
    storageBucket: 'plan-it-app-81de0.firebasestorage.app',
    measurementId: 'G-YR5HNJNRBE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTvLTdApSVL0t3qmOUeiEtK2GcYkimsA8',
    appId: '1:635366621715:android:815674c7aef91641b7b5e6',
    messagingSenderId: '635366621715',
    projectId: 'plan-it-app-81de0',
    storageBucket: 'plan-it-app-81de0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsUYMzlDUtrO6iLQYKWlD_wfVv6LflFbA',
    appId: '1:635366621715:ios:f406729b056a479fb7b5e6',
    messagingSenderId: '635366621715',
    projectId: 'plan-it-app-81de0',
    storageBucket: 'plan-it-app-81de0.firebasestorage.app',
    iosBundleId: 'com.example.planitMt',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDsUYMzlDUtrO6iLQYKWlD_wfVv6LflFbA',
    appId: '1:635366621715:ios:f406729b056a479fb7b5e6',
    messagingSenderId: '635366621715',
    projectId: 'plan-it-app-81de0',
    storageBucket: 'plan-it-app-81de0.firebasestorage.app',
    iosBundleId: 'com.example.planitMt',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAnbl4liCC6xPKc4VeWvhHA8opKKCVjktY',
    appId: '1:635366621715:web:d1daddc1a7b39375b7b5e6',
    messagingSenderId: '635366621715',
    projectId: 'plan-it-app-81de0',
    authDomain: 'plan-it-app-81de0.firebaseapp.com',
    storageBucket: 'plan-it-app-81de0.firebasestorage.app',
    measurementId: 'G-W4PHGSD35F',
  );
}

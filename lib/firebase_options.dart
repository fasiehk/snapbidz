import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCPJs9GOp6Z253LDoj_f3Q23tXViA_evao',
    appId: '1:32940324749:web:c307aa257ce00db0ffefc4',
    messagingSenderId: '32940324749',
    projectId: 'snapbid-fa390',
    authDomain: 'snapbid-fa390.firebaseapp.com',
    storageBucket: 'snapbid-fa390.firebasestorage.app',
    measurementId: 'G-2S12Q9L43M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUZUAvSF8dVvn8pCUD3RzCASZE_7j6hMc',
    appId: '1:32940324749:android:bfaf4edb2c0a4d12ffefc4',
    messagingSenderId: '32940324749',
    projectId: 'snapbid-fa390',
    authDomain: 'snapbid-fa390.firebaseapp.com',
    storageBucket: 'snapbid-fa390.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUZUAvSF8dVvn8pCUD3RzCASZE_7j6hMc',
    appId: '1:32940324749:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '32940324749',
    projectId: 'snapbid-fa390',
    authDomain: 'snapbid-fa390.firebaseapp.com',
    storageBucket: 'snapbid-fa390.firebasestorage.app',
    iosBundleId: 'com.fasiehklasson.snapbid',
  );
}

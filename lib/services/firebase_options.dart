import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions has not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDIRaTPS_FjjPk_Sw21iW_gy0KNE490D-8',
    appId: '1:451264260248:web:42890d2cf244341bc8c8ed',
    messagingSenderId: '451264260248',
    projectId: 'village-attack',
    authDomain: 'village-attack.firebaseapp.com',
    storageBucket: 'village-attack.appspot.com',
    measurementId: 'G-3TSSN1G1VC',
  );
}

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: 'AIzaSyBeLnnXZT0Hm5x0jIBFcDnJCobkGzY32jI',
      appId: '1:117983021252:ios:0ce92111befea598de2191',
      messagingSenderId: '117983021252',
      projectId: 'info6350-garagesale',
      storageBucket: 'info6350-garagesale.firebasestorage.app',
      iosBundleId: 'com.example.garagesale',
    ));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}
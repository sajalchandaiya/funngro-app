import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants/themes/app_theme.dart';
import 'helpers/fake_backend.dart';
import 'helpers/http_helper.dart';
import 'screens/home_screen.dart';

void main() {
  // DEMO ONLY: there is no real backend, so HttpHelper talks to a fake one.
  HttpHelper.client = fakeBackendClient();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Funngro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

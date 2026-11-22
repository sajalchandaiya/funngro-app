import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      theme: _funngroTheme,
      home: const HomeScreen(),
    );
  }
}

// Colours taken from funngro.com (dark green theme).
const _background = Color(0xFF06130A);
const _card = Color(0xFF101913);
const _muted = Color(0xFF1A2920);
const _border = Color(0xFF192920);
const _primary = Color(0xFF07AB5F); // brand green
const _accent = Color(0xFF5FDD96); // light green
const _text = Color(0xFFE7F3EB);
const _textMuted = Color(0xFF7D9785);
const _error = Color(0xFFDD3C3C);

final _funngroTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: _primary,
    onPrimary: _background,
    secondary: _accent,
    onSecondary: _background,
    error: _error,
    onError: Colors.white,
    surface: _background,
    onSurface: _text,
    onSurfaceVariant: _textMuted,
    surfaceContainerHighest: _card,
    primaryContainer: _muted,
    onPrimaryContainer: _accent,
    outline: _border,
    outlineVariant: _border,
  ),
  scaffoldBackgroundColor: _background,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: _background,
    foregroundColor: _text,
    surfaceTintColor: Colors.transparent,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _primary,
    foregroundColor: _background,
  ),
  dividerColor: _border,
);

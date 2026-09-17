import 'package:flutter/material.dart';

import 'package:mobile/auth.dart';
import 'package:mobile/pages/auth/login_page.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AKTIVA',

      theme: AppTheme.light,

      // Named route kept so flows that use pushNamed (e.g. after deleting an
      // account) can always resolve the login screen.
      routes: {'/login': (context) => const LoginPage()},

      home: const AuthCheck(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/auth_screen.dart';
import 'package:frontend/features/auth/otp_screen.dart';
import 'package:frontend/features/wallet/wallet_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/wallet',           // ← start here for now

      debugLogDiagnostics: true,

      redirect: null,                      // ← completely disable redirect for testing

      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) => const OtpScreen(),
        ),
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletScreen(),
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Page not found\n${state.uri}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
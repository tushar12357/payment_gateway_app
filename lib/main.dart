import 'package:flutter/material.dart';
import 'package:frontend/features/wallet/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = AppRouter.createRouter(context);

          return MaterialApp.router(
            title: 'Your Payment App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
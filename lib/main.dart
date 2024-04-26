import 'package:binance_app/presentation/screens/home/tabs/home/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/sign_in/sign_in_screen.dart';
import 'presentation/screens/sign_up/sign_up_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/shared/theme/app_theme.dart';
import 'package:binance_app/data/models/cripto_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(child: MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routes: {
          SplashScreen.route: (_) => const SplashScreen(),
          AuthScreen.route: (_) => const AuthScreen(),
          SignInScreen.route: (_) => const SignInScreen(),
          SignUpScreen.route: (_) => const SignUpScreen(),
          HomeScreen.route: (_) => const HomeScreen(),
          DetailScreen.routeName: (context) {
            final symbol = ModalRoute.of(context)!.settings.arguments as Symbol;

            return DetailScreen(symbol: symbol);
          },
        },
      ),
    );
  }
}

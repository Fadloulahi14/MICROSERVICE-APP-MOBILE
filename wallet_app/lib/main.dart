import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/theme.dart';
import 'services/auth_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthState().init();
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portefeuille Nikitin',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'SN'),
      supportedLocales: const [Locale('fr', 'SN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.orange,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
      ),
      home: ListenableBuilder(
        listenable: AuthState(),
        builder: (context, _) {
          if (AuthState().isAuthenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

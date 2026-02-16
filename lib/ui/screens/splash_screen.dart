import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';

/// Écran de splash : logo + "Seedaily" en couleur secondaire sur fond blanc.
/// S'affiche au démarrage puis redirige vers l'accueil.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 5000), () {
        if (!mounted) return;
        FlutterNativeSplash.remove();
        context.go('/');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Seedaily',
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

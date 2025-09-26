import 'package:depanvite/pages/auth_screen.dart';
import 'package:depanvite/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser le contrôleur d'animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000), // 3 secondes
      vsync: this,
    );

    // Animation de glissement depuis la gauche vers le centre
    _slideAnimation =
        Tween<double>(
          begin: -1.0, // Commence hors écran à gauche
          end: 0.0, // Se termine au centre
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic, // Courbe pour un effet naturel
          ),
        );

    // Animation de fondu pour les autres éléments
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0), // Commence à la moitié de l'animation
      ),
    );

    // Démarrer l'animation
    _animationController.forward();
    // Navigation automatique après l'animation
    _navigateToAuth();
  }

  void _navigateToAuth() async {
    // Attendre que l'animation soit terminée + 2 seconde d'affichage
    await Future.delayed(const Duration(milliseconds: 4000));

    if (mounted) {
      // Navigation avec transition fluide
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animation de fondu
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo animé qui glisse depuis la gauche
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _slideAnimation.value * MediaQuery.of(context).size.width,
                      0,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Nom de l'app qui apparaît en fondu
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: SvgPicture.asset('assets/app-name.svg'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Texte descriptif qui apparaît en fondu
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: Text(
                        'Service de dépannage d\'urgence à portée de main',
                        style: TextStyle(fontSize: 18, color: AppTheme.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

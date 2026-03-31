import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/dashboard/presentation/pages/main_navigation_page.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';

class SplashScreenPage extends ConsumerStatefulWidget {
  const SplashScreenPage({super.key});

  @override
  ConsumerState<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends ConsumerState<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _navigateToDashboard();
  }

  void _navigateToDashboard() async {
    // Wait for 3 seconds for the animation to play
    await Future.delayed(const Duration(milliseconds: 3200));
    
    if (!mounted) return;

    // Smooth navigation to Dashboard
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final themeColor = AppColors.themeColors[profile.avatarIndex % AppColors.themeColors.length];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor.withValues(alpha: 0.9),
              themeColor.withValues(alpha: 0.7),
              Colors.black,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background patterns
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withValues(alpha: 0.1),
                ),
              ),
            ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.5, 0.5)),

            // Main Logo & Branding
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The Finalized Logo (Maximized for the new clean asset)
                Container(
                  width: 380, // Increased for a more dominant brand presence
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.2),
                        blurRadius: 60,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.contain,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack)
                .shimmer(delay: 1.seconds, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.5)),

                const SizedBox(height: 24),
                
                // App Name
                Text(
                  'MyLife OS',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0)
                .blur(begin: const Offset(10, 10), end: Offset.zero),
              ],
            ),
            
            // Bottom Loading Indicator (Subtle)
            Positioned(
              bottom: 80,
              child: SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
              .animate()
              .fadeIn(delay: 1500.ms)
              .scale(begin: const Offset(0.8, 1)),
            ),
          ],
        ),
      ),
    );
  }
}

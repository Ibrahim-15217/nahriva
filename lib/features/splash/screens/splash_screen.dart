import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nahriva/core/constants/routes.dart';
import 'package:nahriva/core/services/onboarding_service.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final onboardingComplete = await OnboardingService.isOnboardingComplete();
    if (!mounted) return;

    if (onboardingComplete) {
      context.go(Routes.home);
    } else {
      context.go(Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_rounded,
              size: 100,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nahriva',
              style: AppTypography.headline1.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Beyond The Drain',
              style: AppTypography.body.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

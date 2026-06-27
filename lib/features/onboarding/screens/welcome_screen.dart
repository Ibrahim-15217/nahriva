import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nahriva/core/constants/routes.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  size: 60,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Nahriva',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Join a community of environmental champions working together to protect our waterways. Every report, every scan, every action counts.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go(Routes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textOnPrimary,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nahriva/core/constants/routes.dart';
import 'package:nahriva/core/services/onboarding_service.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';
import 'package:nahriva/features/onboarding/widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.report_problem_rounded,
      title: 'Report Waste',
      description:
          'Snap a photo, tag the waste type, and report it. Your reports help communities track pollution and take action.',
    ),
    OnboardingPage(
      icon: Icons.visibility_rounded,
      title: 'AI-Powered Identification',
      description:
          'Use EcoLens to identify waste types instantly with AI. Know exactly what you\'re dealing with and how to dispose of it.',
    ),
    OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'Earn Rewards',
      description:
          'Complete challenges, earn points, unlock badges, and climb the leaderboard. Every action you take makes a difference.',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Future<void> _skip() async {
    await OnboardingService.markOnboardingComplete();
    if (!mounted) return;
    context.go(Routes.welcome);
  }

  Future<void> _next() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await OnboardingService.markOnboardingComplete();
      if (!mounted) return;
      context.go(Routes.welcome);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

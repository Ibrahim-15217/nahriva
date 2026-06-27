import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nahriva/features/splash/screens/splash_screen.dart';
import 'package:nahriva/features/onboarding/screens/onboarding_screen.dart';
import 'package:nahriva/features/onboarding/screens/welcome_screen.dart';
import 'package:nahriva/features/auth/presentation/screens/login_screen.dart';
import 'package:nahriva/features/auth/presentation/screens/register_screen.dart';
import 'package:nahriva/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:nahriva/features/home/screens/home_shell.dart';
import 'package:nahriva/features/home/screens/home_screen.dart';
import 'package:nahriva/features/home/screens/map_screen.dart';
import 'package:nahriva/features/home/screens/ecolens_screen.dart';
import 'package:nahriva/features/home/screens/profile_screen.dart';
import 'package:nahriva/core/constants/routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: Routes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: Routes.login,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.register,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.ecolens,
              builder: (context, state) => const EcoLensScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.reportFeed,
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

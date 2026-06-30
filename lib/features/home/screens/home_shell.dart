import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nahriva/core/theme/app_colors.dart';

class NavigationShellScope extends InheritedWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShellScope({super.key,
    required this.navigationShell,
    required super.child,
  });

  static StatefulNavigationShell of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NavigationShellScope>();
    assert(scope != null, 'No NavigationShellScope found in context');
    return scope!.navigationShell;
  }

  @override
  bool updateShouldNotify(NavigationShellScope oldWidget) => true;
}

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationShellScope(
        navigationShell: navigationShell,
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.visibility_outlined),
            selectedIcon: Icon(Icons.visibility_rounded),
            label: 'EcoLens',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBar(
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            backgroundColor: theme.colorScheme.surface,
            indicatorColor: theme.colorScheme.primary.withAlpha(1),
            animationDuration: const Duration(milliseconds: 500),
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/history');
                  break;
                case 1:
                  context.go('/home');
                  break;
                case 2:
                  context.go('/settings');
                  break;
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/history')) return 0;
    if (location.startsWith('/home')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 1;
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:random_cat_facts/nav_bar/nav_bar.dart';
import 'package:random_cat_facts/screens/favorite/favorite_page.dart';
import 'package:random_cat_facts/screens/home/home_page.dart';
import 'package:random_cat_facts/screens/settings/settings_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return CustomNavigationBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const FavoriteFactsPage(),
          ),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

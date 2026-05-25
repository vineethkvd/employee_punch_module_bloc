import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/admin_login_screen.dart';
import '../../features/employee_punch/presentation/pages/punch_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/punch',
      builder: (context, state) => const PunchScreen(),
    ),
  ],
);

import 'package:flutter_dashboard/dashboard.dart';
import 'package:flutter_dashboard/register.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dashboard/login.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final arguments  = state.extra as Map<String, dynamic>?;
        return DashboardPage(
        userArgs: arguments

        );
      }
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/addresses/presentation/pages/addresses_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/pages/dashboard_shell.dart';
import '../features/help/presentation/pages/help_page.dart';
import '../features/invite/presentation/pages/invite_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/services/presentation/pages/services_page.dart';
import '../features/shipments/presentation/pages/shipments_page.dart';
import '../features/wallet/presentation/pages/wallet_page.dart';
import 'route_names.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  static const _guestOnlyRoutes = [
    RouteNames.login,
    RouteNames.signup,
    RouteNames.otp,
    RouteNames.forgotPassword,
    RouteNames.resetPassword,
  ];

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.dashboard,
    refreshListenable: authProvider,
    redirect: _guard,
    routes: [
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final flow = extra?['flow'] as String? ?? 'registration';
          return OtpPage(email: email, flow: flow);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          return ResetPasswordPage(email: email);
        },
      ),
      ShellRoute(
        builder: (_, __, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: RouteNames.shipments,
            builder: (_, __) => const ShipmentsPage(),
          ),
          GoRoute(
            path: RouteNames.services,
            builder: (_, __) => const ServicesPage(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, __) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteNames.wallet,
            builder: (_, __) => const WalletPage(),
          ),
          GoRoute(
            path: RouteNames.addresses,
            builder: (_, __) => const AddressesPage(),
          ),
          GoRoute(
            path: RouteNames.invite,
            builder: (_, __) => const InvitePage(),
          ),
          GoRoute(
            path: RouteNames.help,
            builder: (_, __) => const HelpPage(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final isAuth = authProvider.isAuthenticated;
    final location = state.matchedLocation;
    final isGuestOnly = _guestOnlyRoutes.contains(location);

    if (!isAuth && !isGuestOnly) return RouteNames.login;
    if (isAuth && isGuestOnly) return RouteNames.dashboard;
    return null;
  }
}

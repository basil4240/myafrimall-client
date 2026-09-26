import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../widgets/app_sidebar.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: isDesktop ? null : _buildMobileAppBar(context, isDark),
      drawer: isDesktop
          ? null
          : Container(
        color: Color(0xFFFAFAFA),
            child: Drawer(
                    width: AppSizes.sidebarWidth,
                    child: Builder(
            builder: (ctx) => AppSidebar(
              onClose: () => Navigator.of(ctx).pop(),
            ),
                    ),
                  ),
          ),
      body: isDesktop
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: AppSizes.sidebarWidth,
            child: AppSidebar(),
          ),
          Expanded(child: child),
        ],
      )
          : child,
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context, bool isDark) {
    return AppBar(
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      // title: Text(
      //   'myafrimall',
      //   style: AppTextStyles.h6.copyWith(color: AppColors.primary),
      // ),
      centerTitle: false,
      actions: [
        // Theme toggle - handy for testing light/dark
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: AppSizes.iconMd,
          ),
          onPressed: () => context.read<ThemeProvider>().toggleTheme(),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
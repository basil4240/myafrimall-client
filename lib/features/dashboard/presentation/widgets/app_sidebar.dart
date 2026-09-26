import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../router/route_names.dart';
import '../../../auth/providers/auth_provider.dart';
import 'nav_item_data.dart';

class AppSidebar extends StatelessWidget {
  final VoidCallback? onClose;

  const AppSidebar({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(isDark),
          _divider(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              children: kNavItems.map((item) {
                final isActive = location == item.route ||
                    location.startsWith('${item.route}/');
                return _NavItem(
                  item: item,
                  isActive: isActive,
                  isDark: isDark,
                  onTap: () {
                    onClose?.call();
                    context.go(item.route);
                  },
                );
              }).toList(),
            ),
          ),
          _divider(isDark),
          _buildUserSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return SizedBox(
      height: 108,
    );

    //   Padding(
    //   padding: const EdgeInsets.symmetric(
    //     horizontal: AppSpacing.md,
    //     vertical: AppSpacing.lg,
    //   ),
    //   child: Image.asset(
    //     AppAssets.appLogo,
    //     height: 28,
    //     alignment: Alignment.centerLeft,
    //     fit: BoxFit.contain,
    //     errorBuilder: (_, __, ___) => Text(
    //       'myafrimall',
    //       style: AppTextStyles.h6.copyWith(color: AppColors.primary),
    //     ),
    //   ),
    // );
  }

  Widget _divider(bool isDark) => Divider(
    height: 1,
    thickness: 1,
    color: isDark ? AppColors.borderDark : AppColors.borderLight,
  );

  Widget _buildUserSection(BuildContext context, bool isDark) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final user = context.watch<AuthProvider>().currentUser;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              onClose?.call();
              context.go(RouteNames.profile);
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarSm,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user?.avatar != null
                        ? NetworkImage(user!.avatar!)
                        : null,
                    child: user?.avatar == null
                        ? Text(
                            user?.initials ?? '--',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.firstName ?? '--',
                          style: AppTextStyles.labelLg.copyWith(
                              color: textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.lastName ?? '--',
                          style: AppTextStyles.bodySm.copyWith(
                              color: textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () {
              onClose?.call();
              context.read<AuthProvider>().logout();
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: AppSizes.iconMd,
                    color: textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Logout',
                    style: AppTextStyles.labelLg.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavItemData item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg =
    isDark ? AppColors.navActiveBgDark : AppColors.navActiveBg;
    final activeColor = AppColors.white;
    final inactiveColor =
    isDark ? AppColors.navInactiveDark : AppColors.navInactiveLight;
    final iconColor = isActive ? activeColor : inactiveColor;
    final textColor = isActive ? activeColor : inactiveColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          hoverColor: isActive
              ? null
              : AppColors.primary.withOpacity(0.04),
          child: Ink(
            decoration: BoxDecoration(
              color: isActive ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: AppSizes.iconMd, color: iconColor),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTextStyles.navItem.copyWith(color: textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
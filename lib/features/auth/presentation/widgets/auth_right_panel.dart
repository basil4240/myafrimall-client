import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class AuthRightPanel extends StatelessWidget {
  final String title;
  final String description;

  const AuthRightPanel({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Stack(
        children: [
          // World map graphic - add asset later
          Positioned.fill(
            child: Image.asset(
              AppAssets.authWorldMap,
              fit: BoxFit.cover,
              // Silently falls back to plain bg if asset not yet added
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // color overlay
          Positioned.fill(
            child: Container(
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
          ),

          // Bottom text overlay
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.xxxl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(color: AppColors.white, fontWeight: FontWeight.w600, height: 35/24),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  description,
                  style: AppTextStyles.bodyLg.copyWith(
                  fontSize: 18, height: 30/18,
                    color: AppColors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

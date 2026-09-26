import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/constants.dart';

// Base building blocks

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor:
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      highlightColor:
      isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) => SkeletonBox(
    width: size,
    height: size,
    borderRadius: AppRadius.full,
  );
}

class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonText({super.key, this.width, this.height = 14});

  @override
  Widget build(BuildContext context) => SkeletonBox(
    width: width,
    height: height,
    borderRadius: AppRadius.xs,
  );
}

// Composite skeletons - reused across pages

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const SkeletonCircle(size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: MediaQuery.of(context).size.width * 0.4),
                const SizedBox(height: AppSpacing.sm),
                const SkeletonText(width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) => SkeletonBox(
    height: height,
    borderRadius: AppRadius.md,
  );
}

class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonCircle(size: 40),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonText(width: 80),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonText(width: 48, height: 24),
      ],
    );
  }
}

// Page-level skeletons

class ShipmentListSkeleton extends StatelessWidget {
  const ShipmentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
            (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: SkeletonText(width: 140)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: SkeletonText(width: 100)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: SkeletonText(width: 80)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressListSkeleton extends StatelessWidget {
  const AddressListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
            (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: const SkeletonCard(height: 90),
        ),
      ),
    );
  }
}

class DashboardOverviewSkeleton extends StatelessWidget {
  const DashboardOverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonCard(height: 170),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(child: const SkeletonCard(height: 110)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: const SkeletonStatCard()),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: const SkeletonStatCard()),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: const SkeletonStatCard()),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../data/models/shipment_model.dart';

enum ShipmentFilter { all, inTransit, delayed, paid, pending, cancelled }

extension ShipmentFilterX on ShipmentFilter {
  String get label => switch (this) {
    ShipmentFilter.all => 'All',
    ShipmentFilter.inTransit => 'In-Transit',
    ShipmentFilter.delayed => 'Delayed',
    ShipmentFilter.paid => 'Paid',
    ShipmentFilter.pending => 'Pending',
    ShipmentFilter.cancelled => 'Cancelled',
  };

  bool matches(ShipmentStatus status) => switch (this) {
    ShipmentFilter.all => true,
    ShipmentFilter.inTransit => status == ShipmentStatus.inTransit,
    ShipmentFilter.delayed => status == ShipmentStatus.delayed,
    ShipmentFilter.paid => status == ShipmentStatus.paid,
    ShipmentFilter.pending => status == ShipmentStatus.pending,
    ShipmentFilter.cancelled => status == ShipmentStatus.cancelled,
  };
}

class ShipmentFilterTabs extends StatelessWidget {
  final ShipmentFilter selected;
  final ValueChanged<ShipmentFilter> onChanged;

  const ShipmentFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ShipmentFilter.values.map((filter) {
            return _FilterTab(
              label: filter.label,
              isSelected: filter == selected,
              isDark: isDark,
              onTap: () => onChanged(filter),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
    isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final color = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelLg.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
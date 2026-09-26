import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../data/models/shipment_model.dart';

class ShipmentStatusBadge extends StatelessWidget {
  final ShipmentStatus status;

  const ShipmentStatusBadge({super.key, required this.status});

  (String label, Color fg, Color bg) get _style => switch (status) {
    ShipmentStatus.pending => (
    'Pending',
    AppColors.statShipmentFg,
    AppColors.statShipmentBg,
    ),
    ShipmentStatus.inTransit => (
    'In-Transit',
    AppColors.statusInTransitFg,
    AppColors.statusInTransitBg,
    ),
    ShipmentStatus.delayed => (
    'Delayed',
    AppColors.statusDelayedFg,
    AppColors.statusDelayedBg,
    ),
    ShipmentStatus.paid => (
    'Paid',
    AppColors.success,
    const Color(0xFFDCFCE7),
    ),
    ShipmentStatus.cancelled => (
    'Cancelled',
    AppColors.statusPaidFg,
    AppColors.statusPaidBg,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = _style;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(color: fg),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../data/models/shipment_model.dart';
import 'shipment_status_badge.dart';

class ShipmentListItem extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;
  final bool isDesktop;

  const ShipmentListItem({
    super.key,
    required this.shipment,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? _DesktopRow(shipment: shipment, onTap: onTap)
        : _MobileCard(shipment: shipment, onTap: onTap);
  }
}

// ─── Desktop row ──────────────────────────────────────────────────────────────

class _DesktopRow extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;

  const _DesktopRow({required this.shipment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                shipment.trackingId,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.link,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _TwoLineCell(
                primary: shipment.senderName,
                secondary: shipment.senderLocation,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            Expanded(
              flex: 2,
              child: _TwoLineCell(
                primary: shipment.receiverName,
                secondary: shipment.receiverLocation,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            Expanded(
              flex: 2,
              child: ShipmentStatusBadge(status: shipment.status),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₦${shipment.amount.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMd.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(shipment.createdAt),
                style: AppTextStyles.bodyMd.copyWith(color: textSecondary),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.iconMd,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mobile card ──────────────────────────────────────────────────────────────

class _MobileCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;

  const _MobileCard({required this.shipment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shipment.trackingId,
                  style: AppTextStyles.labelLg
                      .copyWith(color: AppColors.link),
                ),
                ShipmentStatusBadge(status: shipment.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _MobileField(
                    label: 'From',
                    value: shipment.senderLocation,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: AppSizes.iconSm,
                  color: textSecondary,
                ),
                Expanded(
                  child: _MobileField(
                    label: 'To',
                    value: shipment.receiverLocation,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₦${shipment.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.labelLg.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDate(shipment.createdAt),
                  style:
                  AppTextStyles.caption.copyWith(color: textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _TwoLineCell extends StatelessWidget {
  final String primary;
  final String secondary;
  final Color textPrimary;
  final Color textSecondary;

  const _TwoLineCell({
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        primary,
        style: AppTextStyles.bodyMd.copyWith(color: textPrimary),
      ),
      Text(
        secondary,
        style: AppTextStyles.caption.copyWith(color: textSecondary),
      ),
    ],
  );
}

class _MobileField extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _MobileField({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.caption.copyWith(color: textSecondary),
      ),
      Text(
        value,
        style: AppTextStyles.bodySm.copyWith(color: textPrimary),
      ),
    ],
  );
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${date.day} ${months[date.month - 1]}, ${date.year}';
}
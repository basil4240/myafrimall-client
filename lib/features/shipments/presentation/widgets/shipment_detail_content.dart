import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/shipment_model.dart';
import 'shipment_status_badge.dart';

class ShipmentDetailContent extends StatelessWidget {
  final Shipment shipment;

  const ShipmentDetailContent({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tracking ID + copy
        Row(
          children: [
            Expanded(
              child: Text(
                shipment.trackingId,
                style: AppTextStyles.h5.copyWith(color: AppColors.link),
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: shipment.trackingId));
                AppToast.success(context, 'Tracking ID copied');
              },
              icon: Icon(
                Icons.copy_rounded,
                size: AppSizes.iconMd,
                color: textSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            ShipmentStatusBadge(status: shipment.status),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatDate(shipment.createdAt),
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Divider(color: borderColor),
        const SizedBox(height: AppSpacing.lg),

        // Sender
        _Section(title: 'Sender', textPrimary: textPrimary),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Name',
          value: shipment.senderName,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Pickup From',
          value: '🇳🇬 ${shipment.senderLocation}',
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Receiver
        _Section(title: 'Receiver', textPrimary: textPrimary),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Name',
          value: shipment.receiverName,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Delivery To',
          value: '🇳🇬 ${shipment.receiverLocation}',
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Package
        _Section(title: 'Package Details', textPrimary: textPrimary),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Weight',
          value: '${shipment.weight} kg',
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Service Type',
          value: shipment.serviceType,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Description',
          value: shipment.description,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Processing Time',
          value: shipment.processingTime,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Payment
        _Section(title: 'Payment', textPrimary: textPrimary),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Amount',
          value:
          '${shipment.currency} ${shipment.amount.toStringAsFixed(0)}',
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Row(
          label: 'Status',
          value: shipment.isPaid ? 'Paid' : 'Unpaid',
          textPrimary:
          shipment.isPaid ? AppColors.success : AppColors.error,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Actions
        if (!shipment.isPaid) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Pay Now'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('Track Shipment'),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Color textPrimary;

  const _Section({required this.title, required this.textPrimary});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: AppTextStyles.labelLg.copyWith(
      color: textPrimary,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _Row({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.bodyMd.copyWith(color: textSecondary),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        ),
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
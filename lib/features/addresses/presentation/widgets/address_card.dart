import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../data/models/address_model.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceBg =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : borderColor,
          width: address.isDefault ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.label,
                  style: AppTextStyles.labelLg.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'Default',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              PopupMenuButton<_Action>(
                onSelected: (action) {
                  switch (action) {
                    case _Action.edit:
                      onEdit?.call();
                    case _Action.delete:
                      onDelete?.call();
                    case _Action.setDefault:
                      onSetDefault?.call();
                  }
                },
                itemBuilder: (_) => [
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: _Action.setDefault,
                      child: Text('Set as default'),
                    ),
                  const PopupMenuItem(
                    value: _Action.edit,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: _Action.delete,
                    child: Text('Delete'),
                  ),
                ],
                child: Icon(
                  Icons.more_vert_rounded,
                  size: AppSizes.iconMd,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            address.fullAddress,
            style: AppTextStyles.bodyMd.copyWith(color: textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${address.city}, ${address.state}, ${address.country}',
            style: AppTextStyles.bodySm.copyWith(color: textSecondary),
          ),
          if (address.postalCode.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              address.postalCode,
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

enum _Action { edit, delete, setDefault }

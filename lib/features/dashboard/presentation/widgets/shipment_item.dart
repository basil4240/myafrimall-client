import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../features/shipments/data/models/shipment_model.dart';
import '../../../../features/shipments/presentation/widgets/shipment_status_badge.dart';

class ShipmentItem extends StatefulWidget {
  final Shipment shipment;
  final bool initiallyExpanded;

  const ShipmentItem({
    super.key,
    required this.shipment,
    this.initiallyExpanded = true,
  });

  @override
  State<ShipmentItem> createState() => _ShipmentItemState();
}

class _ShipmentItemState extends State<ShipmentItem> {
  late bool _isExpanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = AppBreakpoints.isMobileC(constraints.maxWidth);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderBand(
                shipment: widget.shipment,
                isExpanded: _isExpanded,
                isMobile: isMobile,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onToggle: () => setState(() => _isExpanded = !_isExpanded),
              ),
              if (_isExpanded) ...[
                Divider(height: 1, thickness: 1, color: borderColor),
                _DetailBand(
                  shipment: widget.shipment,
                  isMobile: isMobile,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Divider(height: 1, thickness: 1, color: borderColor),
                _ActionBand(
                  shipment: widget.shipment,
                  isMobile: isMobile,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HeaderBand extends StatelessWidget {
  final Shipment shipment;
  final bool isExpanded;
  final bool isMobile;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onToggle;

  const _HeaderBand({
    required this.shipment,
    required this.isExpanded,
    required this.isMobile,
    required this.textPrimary,
    required this.textSecondary,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Field(
                          label: 'Tracking ID',
                          value: shipment.trackingId,
                          valueColor: AppColors.link,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                label: 'Sender',
                                value: shipment.senderName,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ),
                            Expanded(
                              child: _Field(
                                label: 'Receiver',
                                value: shipment.receiverName,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _Field(
                            label: 'Tracking ID',
                            value: shipment.trackingId,
                            valueColor: AppColors.link,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _Field(
                            label: 'Sender',
                            value: shipment.senderName,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: _Field(
                            label: 'Receiver',
                            value: shipment.receiverName,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: textPrimary,
              size: AppSizes.iconLg,
            ),
          ],
        ),
      ),
    );
  }
}

const _currencySymbols = {'NGN': 'N', 'USD': '\$', 'GBP': '£', 'EUR': '€'};

String _formatAmount(String currency, double amount) {
  final grouped = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
  final symbol = _currencySymbols[currency];
  return symbol != null ? '$symbol$grouped' : '$currency $grouped';
}

class _DetailBand extends StatelessWidget {
  final Shipment shipment;
  final bool isMobile;
  final Color textPrimary;
  final Color textSecondary;

  const _DetailBand({
    required this.shipment,
    required this.isMobile,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final pickUp = _Field(
      label: 'Pick Up From',
      value: shipment.senderLocation,
      leading: _FlagIcon(location: shipment.senderLocation),
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );

    final deliveryTo = _Field(
      label: 'Delivery To',
      value: shipment.receiverLocation,
      leading: _FlagIcon(location: shipment.receiverLocation),
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );

    final amount = _Field(
      label: 'Amount',
      value: _formatAmount(shipment.currency, shipment.amount),
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );

    final status = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          'Status',
          style: AppTextStyles.bodySm.copyWith(color: textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        ShipmentStatusBadge(status: shipment.status),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: pickUp),
                    Expanded(child: deliveryTo),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: amount),
                    Expanded(child: status),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: pickUp),
                Expanded(flex: 4, child: deliveryTo),
                Expanded(flex: 3, child: amount),
                Expanded(flex: 2, child: status),
              ],
            ),
    );
  }
}

class _ActionBand extends StatelessWidget {
  final Shipment shipment;
  final bool isMobile;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _ActionBand({
    required this.shipment,
    required this.isMobile,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final processingTime = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Processing time',
          style: AppTextStyles.bodySm.copyWith(color: textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 17, color: textPrimary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              shipment.processingTime,
              style: AppTextStyles.bodyMd.copyWith(color: textPrimary),
            ),
          ],
        ),
      ],
    );

    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _OutlinedAction(
          label: 'View More',
          onPressed: () {},
          borderColor: borderColor,
          textColor: textPrimary,
        ),
        const SizedBox(width: AppSpacing.sm),
        if (shipment.isPaid)
          _PaidChip(textSecondary: textSecondary, isDark: Theme.of(context).brightness == Brightness.dark)
        else
          _FilledAction(label: 'Pay Now', onPressed: () {}),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                processingTime,
                const SizedBox(height: AppSpacing.md),
                buttons,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: processingTime),
                buttons,
              ],
            ),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;

  const _OutlinedAction({
    required this.label,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLg.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _FilledAction({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLg.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PaidChip extends StatelessWidget {
  final Color textSecondary;
  final bool isDark;

  const _PaidChip({required this.textSecondary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 3,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.statusPaidBg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        'Paid',
        style: AppTextStyles.labelLg.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? leading;
  final Color textPrimary;
  final Color textSecondary;

  const _Field({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    this.valueColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySm.copyWith(color: textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.bodyLg.copyWith(
                  color: valueColor ?? textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Renders a small flag swatch for the country named at the end of a
/// "City, Country" location string. Falls back to a neutral pin.
class _FlagIcon extends StatelessWidget {
  final String location;

  const _FlagIcon({required this.location});

  static const _flags = <String, List<Color>>{
    'nigeria': [Color(0xFF008751), Color(0xFFFFFFFF), Color(0xFF008751)],
    'ghana': [Color(0xFFCE1126), Color(0xFFFCD116), Color(0xFF006B3F)],
    'kenya': [Color(0xFF000000), Color(0xFFBB0000), Color(0xFF006600)],
    'france': [Color(0xFF0055A4), Color(0xFFFFFFFF), Color(0xFFEF4135)],
    'italy': [Color(0xFF009246), Color(0xFFFFFFFF), Color(0xFFCE2B37)],
    'ireland': [Color(0xFF169B62), Color(0xFFFFFFFF), Color(0xFFFF883E)],
    'uk': [Color(0xFF012169), Color(0xFFFFFFFF), Color(0xFFC8102E)],
    'united kingdom': [Color(0xFF012169), Color(0xFFFFFFFF), Color(0xFFC8102E)],
    'usa': [Color(0xFF3C3B6E), Color(0xFFFFFFFF), Color(0xFFB22234)],
    'united states': [Color(0xFF3C3B6E), Color(0xFFFFFFFF), Color(0xFFB22234)],
    'canada': [Color(0xFFD80621), Color(0xFFFFFFFF), Color(0xFFD80621)],
    'china': [Color(0xFFDE2910), Color(0xFFFFDE00), Color(0xFFDE2910)],
  };

  List<Color>? get _bands {
    final parts = location.split(',');
    final country = parts.last.trim().toLowerCase();
    return _flags[country];
  }

  @override
  Widget build(BuildContext context) {
    final bands = _bands;
    if (bands == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Icon(
        Icons.place_outlined,
        size: 14,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 16,
        height: 12,
        child: Row(
          // Without stretch the bands get a loose height constraint and a
          // childless ColoredBox collapses to zero.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: bands
              .map((c) => Expanded(child: ColoredBox(color: c)))
              .toList(),
        ),
      ),
    );
  }
}

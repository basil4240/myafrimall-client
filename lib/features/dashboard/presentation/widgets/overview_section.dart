import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../providers/dashboard_provider.dart';
import 'balance_card.dart';
import 'stat_card.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  static const _periodLabels = ['This Week', 'This Month', 'This Year'];
  static const _periodValues = ['week', 'month', 'year'];
  static const _vsLabels = {
    'week': 'Vs last week',
    'month': 'Vs last month',
    'year': 'Vs last year',
  };

  static String _labelFor(String value) {
    final idx = _periodValues.indexOf(value);
    return idx >= 0 ? _periodLabels[idx] : 'This Month';
  }

  static String _valueFor(String label) {
    final idx = _periodLabels.indexOf(label);
    return idx >= 0 ? _periodValues[idx] : 'month';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _PeriodDropdown(
              value: _labelFor(provider.selectedPeriod),
              items: _periodLabels,
              onChanged: (label) => provider.changePeriod(_valueFor(label)),
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cards = _statCards(provider);

            // Desktop: balance card beside all three stats.
            if (AppBreakpoints.isDesktopC(width)) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 2, child: BalanceCard()),
                    const SizedBox(width: AppSpacing.md),
                    for (var i = 0; i < cards.length; i++) ...[
                      Expanded(child: cards[i]),
                      if (i < cards.length - 1)
                        const SizedBox(width: AppSpacing.md),
                    ],
                  ],
                ),
              );
            }

            // Tablet: balance card full width, stats in a single row below.
            if (!AppBreakpoints.isMobileC(width)) {
              return Column(
                children: [
                  const BalanceCard(),
                  const SizedBox(height: AppSpacing.md),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          Expanded(child: cards[i]),
                          if (i < cards.length - 1)
                            const SizedBox(width: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }

            // Mobile: everything stacked.
            return Column(
              children: [
                const BalanceCard(),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < cards.length; i++) ...[
                  cards[i],
                  if (i < cards.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  List<Widget> _statCards(DashboardProvider provider) {
    final stats = provider.overview?.stats;
    final vsLast = stats?.vsLastPeriod ?? 0;
    final vsLabel = _vsLabels[provider.selectedPeriod] ?? 'Vs last month';

    return [
      StatCard(
        title: 'Total Shipment',
        value: '${stats?.totalShipments ?? 0}',
        percentChange: stats?.shipmentsChange.abs() ?? 0,
        isPositive: (stats?.shipmentsChange ?? 0) >= 0,
        vsLastPeriod: vsLast,
        vsLabel: vsLabel,
        icon: Icons.local_shipping_outlined,
        iconColor: AppColors.statShipmentFg,
        iconBgColor: AppColors.statShipmentBg,
      ),
      StatCard(
        title: 'Total Exports',
        value: '${stats?.totalExports ?? 0}',
        percentChange: stats?.exportsChange.abs() ?? 0,
        isPositive: (stats?.exportsChange ?? 0) >= 0,
        vsLastPeriod: vsLast,
        vsLabel: vsLabel,
        icon: Icons.arrow_upward_rounded,
        iconColor: AppColors.statExportFg,
        iconBgColor: AppColors.statExportBg,
      ),
      StatCard(
        title: 'Total Import',
        value: '${stats?.totalImports ?? 0}',
        percentChange: stats?.importsChange.abs() ?? 0,
        isPositive: (stats?.importsChange ?? 0) >= 0,
        vsLastPeriod: vsLast,
        vsLabel: vsLabel,
        icon: Icons.arrow_downward_rounded,
        iconColor: AppColors.statImportFg,
        iconBgColor: AppColors.statImportBg,
      ),
    ];
  }
}

class _PeriodDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _PeriodDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => items
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.labelLg.copyWith(color: textColor),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppSizes.iconSm,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}

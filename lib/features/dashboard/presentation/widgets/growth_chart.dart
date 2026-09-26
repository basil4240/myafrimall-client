import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class GrowthChart extends StatefulWidget {
  const GrowthChart({super.key});

  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> {
  String _period = 'Year';
  static const _periods = ['Year', 'Month', 'Week'];

  static const _yearData = [
    FlSpot(1, 280), FlSpot(2, 300), FlSpot(3, 310),
    FlSpot(4, 380), FlSpot(5, 420), FlSpot(6, 440),
    FlSpot(7, 550), FlSpot(8, 600), FlSpot(9, 640),
    FlSpot(10, 630), FlSpot(11, 750), FlSpot(12, 950),
  ];

  static const _monthData = [
    FlSpot(1, 150), FlSpot(5, 200), FlSpot(10, 280),
    FlSpot(15, 350), FlSpot(20, 420), FlSpot(25, 500),
    FlSpot(30, 580),
  ];

  static const _weekData = [
    FlSpot(1, 100), FlSpot(2, 130), FlSpot(3, 120),
    FlSpot(4, 160), FlSpot(5, 150), FlSpot(6, 180),
    FlSpot(7, 200),
  ];

  List<FlSpot> get _currentData => switch (_period) {
    'Month' => _monthData,
    'Week' => _weekData,
    _ => _yearData,
  };

  double get _maxX => switch (_period) {
    'Month' => 30,
    'Week' => 7,
    _ => 12,
  };

  static String _formatAxisValue(double value) {
    final n = value.toInt();
    return n >= 1000
        ? n.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')
        : '$n';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                'Company Growth',
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              );
              final toggle = _PeriodToggle(
                selected: _period,
                periods: _periods,
                onChanged: (p) => setState(() => _period = p),
                isDark: isDark,
              );

              if (AppBreakpoints.isMobileC(constraints.maxWidth)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: AppSpacing.md),
                    toggle,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Flexible(child: title), toggle],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: borderColor,
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 200,
                      reservedSize: 44,
                      getTitlesWidget: (value, _) => Text(
                        _formatAxisValue(value),
                        style: AppTextStyles.caption
                            .copyWith(color: textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption
                              .copyWith(color: textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: _maxX,
                minY: 0,
                maxY: 1000,
                lineBarsData: [
                  LineChartBarData(
                    spots: _currentData,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.22),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final String selected;
  final List<String> periods;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _PeriodToggle({
    required this.selected,
    required this.periods,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final isSelected = period == selected;
          return GestureDetector(
            onTap: () => onChanged(period),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.cardDark : AppColors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                boxShadow: isSelected && !isDark
                    ? [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.06),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                period,
                style: AppTextStyles.labelLg.copyWith(
                  color: isSelected
                      ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
class DashboardStats {
  final int totalShipments;
  final int totalExports;
  final int totalImports;
  final double shipmentsChange;
  final double exportsChange;
  final double importsChange;
  final int vsLastPeriod;

  const DashboardStats({
    required this.totalShipments,
    required this.totalExports,
    required this.totalImports,
    required this.shipmentsChange,
    required this.exportsChange,
    required this.importsChange,
    required this.vsLastPeriod,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalShipments: json['totalShipments'] as int? ?? 0,
        totalExports: json['totalExports'] as int? ?? 0,
        totalImports: json['totalImports'] as int? ?? 0,
        shipmentsChange:
            (json['shipmentsChange'] as num?)?.toDouble() ?? 0,
        exportsChange: (json['exportsChange'] as num?)?.toDouble() ?? 0,
        importsChange: (json['importsChange'] as num?)?.toDouble() ?? 0,
        vsLastPeriod: json['vsLastPeriod'] as int? ?? 0,
      );
}

class DashboardOverview {
  final double balance;
  final DashboardStats stats;

  const DashboardOverview({required this.balance, required this.stats});

  factory DashboardOverview.fromJson(Map<String, dynamic> json) =>
      DashboardOverview(
        balance: (json['balance'] as num).toDouble(),
        stats: DashboardStats.fromJson(
          json['stats'] as Map<String, dynamic>,
        ),
      );
}

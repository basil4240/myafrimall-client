import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/dashboard_banner.dart';
import '../widgets/overview_section.dart';
import '../widgets/recent_shipments_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite & Earn', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171717)
                ),),
                SizedBox(height: 4,),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: 453
                  ),
                  child: Text('Keep track of your addresses,  location updates. Edit, Delete, Update and see all your saved addresses', style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF737373)
                  ),),
                ),
                SizedBox(
                  height: 11,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 19),
            child: DashboardBanner(),
          ),
          SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 2),
            child: OverviewSection(),
          ),
          SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 2),
            child: RecentShipmentsSection(),
          ),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

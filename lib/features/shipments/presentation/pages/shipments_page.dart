import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../providers/shipments_provider.dart';
import '../../data/models/shipment_model.dart';
import '../widgets/shipment_detail_content.dart';
import '../widgets/shipment_filter_tabs.dart';
import '../widgets/shipment_form_content.dart';
import '../widgets/shipment_list_item.dart';

class ShipmentsPage extends StatefulWidget {
  const ShipmentsPage({super.key});

  @override
  State<ShipmentsPage> createState() => _ShipmentsPageState();
}

class _ShipmentsPageState extends State<ShipmentsPage> {
  ShipmentFilter _filter = ShipmentFilter.all;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentsProvider>().loadShipments(refresh: true);
    });
  }

  List<Shipment> _filtered(List<Shipment> shipments) =>
      shipments.where((s) {
        final matchesFilter = _filter.matches(s.status);
        final q = _search.toLowerCase();
        final matchesSearch = q.isEmpty ||
            s.trackingId.toLowerCase().contains(q) ||
            s.senderName.toLowerCase().contains(q) ||
            s.receiverName.toLowerCase().contains(q);
        return matchesFilter && matchesSearch;
      }).toList();

  void _openDetail(Shipment shipment) {
    AppSheet.showDetail(
      context,
      title: 'Shipment Detail',
      child: ShipmentDetailContent(shipment: shipment),
    );
  }

  void _openCreate() {
    AppSheet.showForm(
      context,
      title: 'New Shipment',
      child: ShipmentFormContent(
        onSuccess: () =>
            AppToast.success(context, 'Shipment created successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShipmentsProvider>(
      builder: (context, provider, _) {
        final filtered = _filtered(provider.shipments);
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = AppBreakpoints.isDesktopC(constraints.maxWidth);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;
            final textSecondary = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shipments',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Track and manage your shipments',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _openCreate,
                        icon: const Icon(
                          Icons.add_rounded,
                          size: AppSizes.iconSm,
                        ),
                        label: Text(isDesktop ? 'New Shipment' : 'New'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _search = val),
                    decoration: InputDecoration(
                      hintText:
                          'Search by tracking ID, sender or receiver...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: AppSizes.iconMd,
                        color: textSecondary,
                      ),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: AppSizes.iconSm,
                                color: textSecondary,
                              ),
                              onPressed: () =>
                                  setState(() => _search = ''),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: ShipmentFilterTabs(
                    selected: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: provider.isLoading && provider.shipments.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: ShipmentListSkeleton(),
                        )
                      : filtered.isEmpty
                          ? _buildEmpty(context, provider, textSecondary)
                          : _buildList(
                              filtered, isDesktop, borderColor, textSecondary),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildList(
    List<Shipment> items,
    bool isDesktop,
    Color borderColor,
    Color textSecondary,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        if (isDesktop) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: _HeaderCell(
                        label: 'Tracking ID', color: textSecondary)),
                Expanded(
                    flex: 2,
                    child: _HeaderCell(label: 'Sender', color: textSecondary)),
                Expanded(
                    flex: 2,
                    child:
                        _HeaderCell(label: 'Receiver', color: textSecondary)),
                Expanded(
                    flex: 2,
                    child: _HeaderCell(label: 'Status', color: textSecondary)),
                Expanded(
                    flex: 2,
                    child: _HeaderCell(label: 'Amount', color: textSecondary)),
                Expanded(
                    flex: 2,
                    child: _HeaderCell(label: 'Date', color: textSecondary)),
                const SizedBox(width: AppSizes.iconMd),
              ],
            ),
          ),
          Divider(color: borderColor),
        ],
        ...items.map(
          (s) => ShipmentListItem(
            key: ValueKey(s.id),
            shipment: s,
            isDesktop: isDesktop,
            onTap: () => _openDetail(s),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildEmpty(
      BuildContext context, ShipmentsProvider provider, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 56,
            color: textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _search.isNotEmpty
                ? 'No shipments match your search'
                : 'No shipments yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your first shipment to get started',
            style: AppTextStyles.bodyMd.copyWith(color: textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _openCreate,
            child: const Text('New Shipment'),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final Color color;

  const _HeaderCell({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: AppTextStyles.labelSm.copyWith(color: color),
      );
}

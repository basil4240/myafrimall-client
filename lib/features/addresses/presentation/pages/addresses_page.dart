import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../providers/addresses_provider.dart';
import '../widgets/address_card.dart';
import '../widgets/address_form_content.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressesProvider>().loadAddresses();
    });
  }

  void _openCreate() {
    AppSheet.showForm(
      context,
      title: 'New Address',
      child: AddressFormContent(
        onSuccess: () =>
            AppToast.success(context, 'Address added'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressesProvider>(
      builder: (context, provider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                        'My Addresses',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Manage your saved addresses',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCreate,
                    icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                    label: const Text('Add Address'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.addresses.isEmpty
                      ? _buildEmpty(context, textSecondary)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: provider.addresses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) {
                            final address = provider.addresses[i];
                            return AddressCard(
                              key: ValueKey(address.id),
                              address: address,
                              onEdit: () => AppSheet.showForm(
                                context,
                                title: 'Edit Address',
                                child: AddressFormContent(
                                  existing: address,
                                  onSuccess: () => AppToast.success(
                                      context, 'Address updated'),
                                ),
                              ),
                              onDelete: () => _confirmDelete(
                                  context, provider, address.id),
                              onSetDefault: () async {
                                final ok =
                                    await provider.setDefault(address.id);
                                if (!context.mounted) return;
                                if (ok) {
                                  AppToast.success(
                                      context, 'Default address updated');
                                } else if (provider.error != null) {
                                  AppToast.error(context, provider.error!);
                                  provider.clearError();
                                }
                              },
                            );
                          },
                        ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, AddressesProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Remove this address from your saved list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await provider.deleteAddress(id);
              if (!context.mounted) return;
              if (ok) {
                AppToast.success(context, 'Address deleted');
              } else if (provider.error != null) {
                AppToast.error(context, provider.error!);
                provider.clearError();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 56,
            color: textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No addresses saved',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your first address to get started',
            style: AppTextStyles.bodyMd.copyWith(color: textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _openCreate,
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}

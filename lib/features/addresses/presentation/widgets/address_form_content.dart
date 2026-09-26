import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/address_model.dart';
import '../../providers/addresses_provider.dart';

class AddressFormContent extends StatefulWidget {
  final Address? existing;
  final VoidCallback? onSuccess;

  const AddressFormContent({
    super.key,
    this.existing,
    this.onSuccess,
  });

  @override
  State<AddressFormContent> createState() => _AddressFormContentState();
}

class _AddressFormContentState extends State<AddressFormContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _fullAddressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _postalCodeCtrl;
  late bool _isDefault;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _labelCtrl = TextEditingController(text: e?.label);
    _fullAddressCtrl = TextEditingController(text: e?.fullAddress);
    _cityCtrl = TextEditingController(text: e?.city);
    _stateCtrl = TextEditingController(text: e?.state);
    _countryCtrl = TextEditingController(text: e?.country ?? 'Nigeria');
    _postalCodeCtrl = TextEditingController(text: e?.postalCode);
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _fullAddressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _postalCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AddressesProvider>();
    final data = {
      'label': _labelCtrl.text.trim(),
      'fullAddress': _fullAddressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'postalCode': _postalCodeCtrl.text.trim(),
      'isDefault': _isDefault,
    };
    final bool ok;
    if (_isEditing) {
      ok = await provider.updateAddress(widget.existing!.id, data);
    } else {
      ok = await provider.addAddress(data);
    }
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
    } else if (provider.error != null) {
      AppToast.error(context, provider.error!);
      provider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'Label',
            controller: _labelCtrl,
            hint: 'e.g. Home, Office',
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Full Address',
            controller: _fullAddressCtrl,
            hint: 'e.g. 14 Allen Avenue, Ikeja',
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormField(
                  label: 'City',
                  controller: _cityCtrl,
                  hint: 'Lagos',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FormField(
                  label: 'State',
                  controller: _stateCtrl,
                  hint: 'Lagos',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormField(
                  label: 'Country',
                  controller: _countryCtrl,
                  hint: 'Nigeria',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FormField(
                  label: 'Postal Code',
                  controller: _postalCodeCtrl,
                  hint: '100001',
                  required: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Checkbox(
                value: _isDefault,
                onChanged: (val) =>
                    setState(() => _isDefault = val ?? false),
              ),
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: () => setState(() => _isDefault = !_isDefault),
                child: Text(
                  'Set as default address',
                  style: AppTextStyles.bodyMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Consumer<AddressesProvider>(
            builder: (context, provider, _) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submit,
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Update Address' : 'Add Address',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool required;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          validator: (val) {
            if (required && (val == null || val.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}

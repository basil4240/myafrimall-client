import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/shipment_model.dart';
import '../../providers/shipments_provider.dart';

class ShipmentFormContent extends StatefulWidget {
  final Shipment? existing;
  final VoidCallback? onSuccess;

  const ShipmentFormContent({
    super.key,
    this.existing,
    this.onSuccess,
  });

  @override
  State<ShipmentFormContent> createState() => _ShipmentFormContentState();
}

class _ShipmentFormContentState extends State<ShipmentFormContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _senderNameCtrl;
  late final TextEditingController _pickupCtrl;
  late final TextEditingController _receiverNameCtrl;
  late final TextEditingController _deliveryCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _descriptionCtrl;
  String _serviceType = 'Standard';

  static const _serviceTypes = ['Standard', 'Express', 'Economy'];
  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _senderNameCtrl = TextEditingController(text: e?.senderName);
    _pickupCtrl = TextEditingController(text: e?.senderLocation);
    _receiverNameCtrl = TextEditingController(text: e?.receiverName);
    _deliveryCtrl = TextEditingController(text: e?.receiverLocation);
    _weightCtrl =
        TextEditingController(text: e != null ? '${e.weight}' : '');
    _descriptionCtrl = TextEditingController(text: e?.description);
    if (e != null) _serviceType = e.serviceType;
  }

  @override
  void dispose() {
    _senderNameCtrl.dispose();
    _pickupCtrl.dispose();
    _receiverNameCtrl.dispose();
    _deliveryCtrl.dispose();
    _weightCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ShipmentsProvider>();
    final bool ok;
    if (_isEditing) {
      ok = await provider.updateShipment(
        id: widget.existing!.id,
        senderName: _senderNameCtrl.text.trim(),
        pickupAddress: _pickupCtrl.text.trim(),
        receiverName: _receiverNameCtrl.text.trim(),
        deliveryAddress: _deliveryCtrl.text.trim(),
        weight: double.parse(_weightCtrl.text.trim()),
        description: _descriptionCtrl.text.trim(),
        serviceType: _serviceType,
      );
    } else {
      ok = await provider.createShipment(
        senderName: _senderNameCtrl.text.trim(),
        pickupAddress: _pickupCtrl.text.trim(),
        receiverName: _receiverNameCtrl.text.trim(),
        deliveryAddress: _deliveryCtrl.text.trim(),
        weight: double.parse(_weightCtrl.text.trim()),
        description: _descriptionCtrl.text.trim(),
        serviceType: _serviceType,
      );
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
          // Sender
          _SectionLabel(label: 'Sender'),
          const SizedBox(height: AppSpacing.sm),
          _FormField(
            label: 'Sender Name',
            controller: _senderNameCtrl,
            hint: 'e.g. Bunmi Tanny',
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Pickup Address',
            controller: _pickupCtrl,
            hint: 'e.g. Lagos, Nigeria',
          ),
          const SizedBox(height: AppSpacing.lg),

          // Receiver
          _SectionLabel(label: 'Receiver'),
          const SizedBox(height: AppSpacing.sm),
          _FormField(
            label: 'Receiver Name',
            controller: _receiverNameCtrl,
            hint: 'e.g. Mercy',
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Delivery Address',
            controller: _deliveryCtrl,
            hint: 'e.g. Oyo, Nigeria',
          ),
          const SizedBox(height: AppSpacing.lg),

          // Package
          _SectionLabel(label: 'Package'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormField(
                  label: 'Weight (kg)',
                  controller: _weightCtrl,
                  hint: '0.0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ServiceTypeField(
                  value: _serviceType,
                  items: _serviceTypes,
                  onChanged: (val) => setState(() => _serviceType = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Description',
            controller: _descriptionCtrl,
            hint: 'Brief description of contents',
            maxLines: 3,
            required: false,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Submit
          Consumer<ShipmentsProvider>(
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
                  _isEditing ? 'Update Shipment' : 'Create Shipment',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: AppTextStyles.labelLg.copyWith(
        color: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
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
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.required = true,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint),
          validator: validator ??
                  (val) {
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

class _ServiceTypeField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _ServiceTypeField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.backgroundLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service Type', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: bg,
          decoration: const InputDecoration(),
          items: items
              .map((item) =>
              DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ],
    );
  }
}
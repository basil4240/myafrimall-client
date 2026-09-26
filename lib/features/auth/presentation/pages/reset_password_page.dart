import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_layout.dart';
import '../../../../core/utils/input_formatters.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _success = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.resetPassword(
      email: widget.email,
      otp: _otpController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (auth.error != null) {
      AppToast.error(context, auth.error!);
      auth.clearError();
      return;
    }

    setState(() => _success = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
        panelTitle: 'Set a new password',
        panelDescription:
            'Enter the OTP sent to your email and create a new password.',
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.email.isEmpty) return _buildInvalidState(context);
    if (_success) return _buildSuccessState(context);
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset your password', style: theme.textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the OTP sent to ${widget.email} and choose a new password.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('OTP code', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _otpController,
            inputFormatters: noWhitespace,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '6-digit code'),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'OTP is required';
              if (val.trim().length != 6) return 'Enter the 6-digit code';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('New password', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _passwordController,
            inputFormatters: noWhitespace,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter new password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: AppSizes.iconMd,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 8) return 'Minimum 8 characters';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Confirm password', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _confirmController,
            inputFormatters: noWhitespace,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              hintText: 'Re-enter new password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: AppSizes.iconMd,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm password';
              if (val != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          ElevatedButton(
            onPressed: auth.isSubmitting ? null : _submit,
            child: auth.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Reset password'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: AppSizes.iconLg,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Password reset!', style: theme.textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your password has been reset successfully. You can now sign in with your new password.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.login),
            child: const Text('Sign in'),
          ),
        ),
      ],
    );
  }

  Widget _buildInvalidState(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: AppSizes.iconLg,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Something went wrong', style: theme.textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'No email address found. Please go back and request a new OTP.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.forgotPassword),
            child: const Text('Request new OTP'),
          ),
        ),
      ],
    );
  }
}

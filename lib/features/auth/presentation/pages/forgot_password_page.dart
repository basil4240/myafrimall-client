import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_layout.dart';
import '../../../../core/utils/input_formatters.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.forgotPassword(email: _emailController.text.trim());

    if (!mounted) return;

    if (auth.error != null) {
      AppToast.error(context, auth.error!);
      auth.clearError();
      return;
    }

    setState(() => _otpSent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
        panelTitle: 'Reset your password',
        panelDescription:
            'Enter your registered email and we\'ll send you an OTP to reset your password.',
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return _otpSent ? _buildSuccessState(context) : _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Forgot your password?', style: theme.textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter your registered email address and we\'ll send you a 6-digit OTP to reset your password.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('Email', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _emailController,
            inputFormatters: noWhitespace,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'user@example.com'),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email';
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
                : const Text('Send OTP'),
          ),
          const SizedBox(height: AppSpacing.lg),

          Center(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Remember your password? '),
                  TextSpan(
                    text: 'Sign in',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.link,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go(RouteNames.login),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final theme = Theme.of(context);
    final email = _emailController.text.trim();

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
            Icons.mark_email_read_outlined,
            color: AppColors.success,
            size: AppSizes.iconLg,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Check your email', style: theme.textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'We\'ve sent a 6-digit OTP to $email. Enter it on the next screen along with your new password.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(
              RouteNames.resetPassword,
              extra: {'email': email},
            ),
            child: const Text('Enter OTP'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            'Didn\'t receive the OTP? Check your spam folder.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

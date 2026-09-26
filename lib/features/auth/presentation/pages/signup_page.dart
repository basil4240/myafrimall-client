import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_layout.dart';
import '../widgets/unverified_email_dialog.dart';
import '../../../../core/utils/input_formatters.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Hardcoded for now - extend later with a country picker package
  static const String _dialCode = '+234';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();

    await auth.signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: email,
      phone: '$_dialCode${_phoneController.text.trim()}',
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (auth.unverifiedEmail) {
      final verify = await UnverifiedEmailDialog.show(context, email: email);
      if (!mounted) return;
      if (verify == true) {
        await auth.resendOtp(email: email);
        if (!mounted) return;
        if (auth.error != null) {
          AppToast.warning(
            context,
            'Could not send OTP. You can retry on the next screen.',
          );
          auth.clearError();
        }
        context.go(
          RouteNames.otp,
          extra: {'email': email, 'flow': 'verify'},
        );
      }
      return;
    }

    if (auth.error != null) {
      AppToast.error(context, auth.error!);
      auth.clearError();
      return;
    }

    context.go(RouteNames.otp, extra: {
      'email': email,
      'flow': 'registration',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
        panelTitle: 'Seamlessly Delivering to Over 300 Countries from Nigeria!',
        panelDescription:
        'Access global markets with our quick shipping from Nigeria! '
            'Fast delivery and easy customs to 300+ countries.',
        child: _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Create an account',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Subtitle with Login link
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(
                  text:
                  'Sign up for Myafrimall and gain unlimited access to shipping to over '
                      '300 countries from Nigeria. Do you already have an account? ',
                ),
                TextSpan(
                  text: 'Login',
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
          const SizedBox(height: AppSpacing.xl),

          // First name & Last name - side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('First name', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(hintText: 'John'),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last name', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(hintText: 'Doe'),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Email
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
          const SizedBox(height: AppSpacing.lg),

          // Phone number
          Text('Phone Number', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _phoneController,
            inputFormatters: noWhitespace,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '8012345678',
              prefixIcon: _DialCodePrefix(
                dialCode: _dialCode,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (val.trim().length < 7) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Password
          Text('Password', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _passwordController,
            inputFormatters: noWhitespace,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter Password',
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
          const SizedBox(height: AppSpacing.xl),

          // Error message
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
                : const Text('Create account'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Terms
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                const TextSpan(
                    text:
                    'By clicking on create account you agree to our '),
                TextSpan(
                  text: 'privacy policy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.link,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.link,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'terms of use',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.link,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.link,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted as its own widget to keep the form readable
class _DialCodePrefix extends StatelessWidget {
  final String dialCode;
  final bool isDark;

  const _DialCodePrefix({
    required this.dialCode,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dialCode,
            style: AppTextStyles.bodyMd.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: AppSizes.iconMd,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
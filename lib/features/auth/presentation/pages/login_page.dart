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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();

    await auth.login(
      email: email,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
        panelTitle: 'Effortlessly Track Your Shipments from Nigeria!',
        panelDescription:
            'Monitor your shipments from Nigeria! Enjoy swift delivery '
            'and seamless customs processing.',
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
          Text('Sign in to your account', style: theme.textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(
                  text: 'Log in to Myafrimall to enjoy seamless shipping to '
                      'over 300 countries right from Nigeria. Don\'t have an '
                      'account yet? ',
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.link,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.go(RouteNames.signup),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('Email', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'user@example.com'),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Password', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _passwordController,
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
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          GestureDetector(
            onTap: () => context.go(RouteNames.forgotPassword),
            child: Text(
              'Forgot Password?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.link,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                : const Text('Login'),
          ),
          const SizedBox(height: AppSpacing.lg),

          RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                const TextSpan(text: 'By clicking on login you agree to our '),
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

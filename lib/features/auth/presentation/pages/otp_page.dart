import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_layout.dart';
import '../widgets/otp_input.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final String flow; // 'registration' | 'verify'

  const OtpPage({
    super.key,
    required this.email,
    this.flow = 'registration',
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otp = '';
  String? _inlineError;
  int _otpInputKey = 0;

  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _verify() async {
    if (_otp.length != 6) {
      setState(() => _inlineError = 'Please enter the complete 6-digit code.');
      return;
    }
    setState(() => _inlineError = null);

    final auth = context.read<AuthProvider>();
    await auth.verifyOtp(email: widget.email, otp: _otp);

    if (!mounted) return;

    if (auth.error != null) {
      AppToast.error(context, auth.error!);
      auth.clearError();
      setState(() {
        _otpInputKey++;
        _otp = '';
      });
      return;
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;

    final auth = context.read<AuthProvider>();
    await auth.resendOtp(email: widget.email);

    if (!mounted) return;

    if (auth.error != null) {
      AppToast.error(context, auth.error!);
      auth.clearError();
      return;
    }

    setState(() {
      _otpInputKey++;
      _otp = '';
      _inlineError = null;
    });
    _startTimer();
    AppToast.success(context, 'OTP resent successfully');
  }

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name[0]}${name[1]}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
        panelTitle: 'Verify your email address',
        panelDescription:
        'Enter the 6-digit code sent to your email to get started with Myafrimall.',
        child: _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter verification code',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'We sent a 6-digit code to '),
              TextSpan(
                text: _maskedEmail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const TextSpan(
                  text: '. Enter it below to verify your account.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // OTP boxes - recreated via ValueKey when resend is clicked or on error
        OtpInput(
          key: ValueKey(_otpInputKey),
          onCompleted: (otp) => setState(() => _otp = otp),
          onChanged: (otp) => setState(() {
            _otp = otp;
            if (_inlineError != null) _inlineError = null;
          }),
        ),
        const SizedBox(height: AppSpacing.md),

        // Inline error
        if (_inlineError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Center(
              child: Text(
                _inlineError!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.error),
              ),
            ),
          ),

        // Countdown / Resend
        Center(
          child: _canResend
              ? RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: "Didn't receive the code? "),
                TextSpan(
                  text: 'Resend OTP',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: auth.isLoading
                        ? textSecondary
                        : AppColors.link,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = auth.isSubmitting ? null : _resend,
                ),
              ],
            ),
          )
              : Text(
            'Resend code in ${_countdown}s',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Verify button
        ElevatedButton(
          onPressed:
          auth.isSubmitting || _otp.length != 6 ? null : _verify,
          child: auth.isSubmitting
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white,
            ),
          )
              : const Text('Verify'),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Wrong email
        Center(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Wrong email? '),
                TextSpan(
                  text: 'Go back',
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
    );
  }
}
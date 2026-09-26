import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import 'auth_right_panel.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String panelTitle;
  final String panelDescription;

  const AuthLayout({
    super.key,
    required this.child,
    required this.panelTitle,
    required this.panelDescription,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppBreakpoints.isDesktopC(constraints.maxWidth);

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _centeredForm(constraints)),
              Expanded(
                child: AuthRightPanel(
                  title: panelTitle,
                  description: panelDescription,
                ),
              ),
            ],
          );
        }

        return _centeredForm(constraints);
      },
    );
  }

  // Vertically centers short forms; scrolls tall ones - works for both breakpoints
  Widget _centeredForm(BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.authFormMaxWidth,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
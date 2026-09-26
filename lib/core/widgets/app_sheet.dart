import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AppSheet {
  AppSheet._();

  /// Create / Edit - dialog on desktop, scrollable bottom sheet on mobile/tablet
  static Future<T?> showForm<T>(
      BuildContext context, {
        required String title,
        required Widget child,
        double maxWidth = 560,
      }) {
    if (AppBreakpoints.isDesktop(context)) {
      return showDialog<T>(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => _FormDialog(
          title: title,
          maxWidth: maxWidth,
          child: child,
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _FormBottomSheet(title: title, child: child),
    );
  }

  /// Detail view - right sheet on desktop, full bottom sheet on mobile/tablet
  static Future<T?> showDetail<T>(
      BuildContext context, {
        required String title,
        required Widget child,
        double sheetWidth = 520,
      }) {
    if (AppBreakpoints.isDesktop(context)) {
      return _showRightSheet<T>(
        context,
        title: title,
        width: sheetWidth,
        child: child,
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _FullBottomSheet(title: title, child: child),
    );
  }

  /// Confirm dialog - same on all breakpoints
  static Future<bool?> showConfirm(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDanger = false,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
      ),
    );
  }

  static Future<T?> _showRightSheet<T>(
      BuildContext context, {
        required String title,
        required Widget child,
        required double width,
      }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, _, __) => _RightSheet(
        title: title,
        width: width,
        child: child,
      ),
      transitionBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }
}

// ─── Shared header ────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _SheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h6.copyWith(color: textPrimary),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              size: AppSizes.iconMd,
              color: textPrimary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

// ─── Form dialog (desktop) ────────────────────────────────────────────────────

class _FormDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final double maxWidth;

  const _FormDialog({
    required this.title,
    required this.child,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
    isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final maxH = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHeader(
              title: title,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form bottom sheet (mobile/tablet) ───────────────────────────────────────

class _FormBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormBottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
    isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DragHandle(),
          _SheetHeader(
            title: title,
            onClose: () => Navigator.of(context).pop(),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg + bottomInset,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full bottom sheet (mobile/tablet detail) ─────────────────────────────────

class _FullBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _FullBottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
    isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          const _DragHandle(),
          _SheetHeader(
            title: title,
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Right sheet (desktop detail) ────────────────────────────────────────────

class _RightSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final double width;

  const _RightSheet({
    required this.title,
    required this.child,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
    isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final borderColor =
    isDark ? AppColors.borderDark : AppColors.borderLight;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: bg,
        child: Container(
          width: width,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: borderColor)),
          ),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: _SheetHeader(
                  title: title,
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Confirm dialog ───────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
    isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h6.copyWith(color: textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.bodyMd.copyWith(color: textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isDanger ? AppColors.error : AppColors.primary,
                    ),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
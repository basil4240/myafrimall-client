import 'package:flutter/material.dart';
import '../constants/constants.dart';

enum ToastType { success, error, info, warning }

class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void show(
      BuildContext context, {
        required String message,
        ToastType type = ToastType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    _removeCurrent();
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          if (_current == entry) {
            entry.remove();
            _current = null;
          }
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.error);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.info);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.warning);

  static void _removeCurrent() {
    _current?.remove();
    _current = null;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  static const _animDuration = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animDuration);
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    final holdDuration = widget.duration - _animDuration;
    Future.delayed(holdDuration, () {
      if (mounted) {
        _controller
            .reverse()
            .then((_) { if (mounted) widget.onDismiss(); });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (Color fg, Color bg, IconData icon) get _style => switch (widget.type) {
    ToastType.success => (
    AppColors.success,
    const Color(0xFFDCFCE7),
    Icons.check_circle_rounded,
    ),
    ToastType.error => (
    AppColors.error,
    const Color(0xFFFEF2F2),
    Icons.error_rounded,
    ),
    ToastType.warning => (
    const Color(0xFFF97316),
    const Color(0xFFFFF7ED),
    Icons.warning_rounded,
    ),
    ToastType.info => (
    AppColors.primary,
    const Color(0xFFEEF2FF),
    Icons.info_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (fg, bg, icon) = _style;

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: fg.withOpacity(0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: fg, size: AppSizes.iconMd),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppTextStyles.bodyMd.copyWith(color: fg),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => _controller
                            .reverse()
                            .then((_) { if (mounted) widget.onDismiss(); }),
                        child: Icon(
                          Icons.close_rounded,
                          size: AppSizes.iconSm,
                          color: fg.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
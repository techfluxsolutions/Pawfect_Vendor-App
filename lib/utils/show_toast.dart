import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

class UToast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
    double bottomOffset = 80,
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Determine colors based on type or custom colors
    Color bgColor;
    Color txtColor;
    IconData? toastIcon;

    if (backgroundColor != null) {
      bgColor = backgroundColor;
      txtColor = textColor ?? Colors.white;
    } else {
      switch (type) {
        case ToastType.success:
          bgColor = Colors.green.shade600;
          txtColor = Colors.white;
          toastIcon = icon ?? Icons.check_circle_outline;
          break;
        case ToastType.error:
          bgColor = Colors.red.shade600;
          txtColor = Colors.white;
          toastIcon = icon ?? Icons.error_outline;
          break;
        case ToastType.warning:
          bgColor = Colors.orange.shade600;
          txtColor = Colors.white;
          toastIcon = icon ?? Icons.warning_amber_outlined;
          break;
        case ToastType.info:
        default:
          bgColor = Colors.grey.shade800;
          txtColor = Colors.white;
          toastIcon = icon ?? Icons.info_outline;
          break;
      }
    }

    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: bottomOffset,
            left: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOutBack, // This curve can overshoot 1.0
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value, // Scale can be > 1.0 (which is fine)
                    child: Opacity(
                      opacity: value.clamp(
                        0.0,
                        1.0,
                      ), // ✅ FIX: Clamp the opacity value
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (toastIcon != null) ...[
                              Icon(toastIcon, color: txtColor, size: 20),
                              SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: txtColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  // Convenience methods
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: ToastType.success,
      duration: duration ?? Duration(seconds: 2),
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: ToastType.error,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  static void info(BuildContext context, String message, {Duration? duration}) {
    show(
      context,
      message,
      type: ToastType.info,
      duration: duration ?? Duration(seconds: 2),
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: ToastType.warning,
      duration: duration ?? Duration(seconds: 2),
    );
  }
}

// Alternative: Simple function version
void showToast(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  bool isError = false,
  bool isSuccess = false,
  Duration duration = const Duration(seconds: 2),
  IconData? icon,
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  // Determine color
  Color toastColor;
  IconData? toastIcon;

  if (backgroundColor != null) {
    toastColor = backgroundColor;
  } else if (isError) {
    toastColor = Colors.red.shade600;
    toastIcon = Icons.error_outline;
  } else if (isSuccess) {
    toastColor = Colors.green.shade600;
    toastIcon = Icons.check_circle_outline;
  } else {
    toastColor = Colors.grey.shade800;
    toastIcon = Icons.info_outline;
  }

  if (icon != null) toastIcon = icon;

  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          bottom: 80,
          left: MediaQuery.of(context).size.width * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: toastColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (toastIcon != null) ...[
                    Icon(toastIcon, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

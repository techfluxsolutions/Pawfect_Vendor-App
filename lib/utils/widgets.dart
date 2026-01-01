import 'package:flutter/material.dart';

// ============================================
// RESPONSIVE CONTAINER - Centers content on all devices
// ============================================
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.maxWidth = 450,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24),
        child: child,
      ),
    );
  }
}

// ============================================
// RESPONSIVE SCAFFOLD - Full responsive layout
// ============================================
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final double maxWidth;
  final bool scrollable;

  const ResponsiveScaffold({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.appBar,
    this.maxWidth = 450,
    this.scrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: maxWidth),
            child:
                scrollable
                    ? SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: child,
                    )
                    : Padding(padding: EdgeInsets.all(24), child: child),
          ),
        ),
      ),
    );
  }
}

// ============================================
// CUSTOM BUTTON - Uses theme colors
// ============================================
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side:
              foregroundColor != null
                  ? BorderSide(color: foregroundColor!)
                  : null,
        ),
        child: _buildChild(theme),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: _buildChild(theme),
    );
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.onPrimary,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 20), SizedBox(width: 8), Text(text)],
      );
    }

    return Text(text);
  }
}

// ============================================
// CUSTOM TEXT FIELD - Uses theme colors
// ============================================
class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final bool enabled;
  final int maxLines;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.onChanged,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        counterText: '', // Hide counter
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ============================================
// CUSTOM PASSWORD FIELD
// ============================================
class CustomPasswordField extends StatefulWidget {
  final String labelText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? errorText;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    Key? key,
    this.labelText = 'Password',
    this.onChanged,
    this.controller,
    this.errorText,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: widget.labelText,
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      errorText: widget.errorText,
      validator: widget.validator,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
    );
  }
}

// ============================================
// LOADING OVERLAY
// ============================================
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({Key? key, required this.isLoading, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

// ============================================
// SCREEN SIZE HELPER
// ============================================
class ScreenSize {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
}

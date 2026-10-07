import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Primary call-to-action. Full width, basic style.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppText.label.copyWith(fontSize: 14),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Secondary action: outlined button
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color background;
  final Color foreground;
  final Color borderColor;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 44,
    this.background = AppColors.surface,
    this.foreground = AppColors.primary,
    this.borderColor = AppColors.border,
  });

  /// Restrained destructive variant used for delete actions.
  const AppSecondaryButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 44,
  }) : background = AppColors.surface,
       foreground = AppColors.danger,
       borderColor = AppColors.border;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppText.label.copyWith(fontSize: 14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

/// Labelled text field matching the shared design system.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final multiline = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          onSubmitted: onSubmitted,
          enabled: enabled,
          cursorColor: AppColors.primary,
          style: AppText.body.copyWith(color: AppColors.textPrimary),
          decoration: AppInput.decoration(
            hint: hint,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: multiline ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Uppercase section label
class AppSectionTitle extends StatelessWidget {
  final String title;

  const AppSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title.toUpperCase(), style: AppText.eyebrow);
  }
}

/// Group of related form fields introduced by a small section heading.
class AppFormSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;

  const AppFormSection({
    super.key,
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionTitle(title),
        if (description != null) ...[
          const SizedBox(height: 6),
          Text(description!, style: AppText.caption),
        ],
        const SizedBox(height: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: children,
        ),
      ],
    );
  }
}

/// Label above an arbitrary field such as a dropdown.
class AppFieldShell extends StatelessWidget {
  final String label;
  final Widget child;

  const AppFieldShell({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Simple tag used for categories and statuses.
class AppTag extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final double fontSize;

  const AppTag({
    super.key,
    required this.label,
    this.background = AppColors.subtleFill,
    this.foreground = AppColors.textSecondary,
    this.fontSize = 11,
  });

  const AppTag.primary({
    super.key,
    required this.label,
    this.fontSize = 11,
  }) : background = AppColors.primaryLight,
       foreground = AppColors.primary;

  const AppTag.danger({super.key, required this.label, this.fontSize = 11})
    : background = AppColors.dangerLight,
      foreground = AppColors.danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.eyebrow.copyWith(
          color: foreground,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Consistent loading state.
class AppLoading extends StatelessWidget {
  final double size;

  const AppLoading({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Consistent empty state.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRefresh;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.bodySecondary,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppText.label,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Consistent error state.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'Error',
    this.message = 'Content could not be loaded.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.bodySecondary,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppText.label,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Hairline divider used between sections and list items.
class AppDivider extends StatelessWidget {
  final double height;

  const AppDivider({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    return Container(height: height, color: AppColors.border);
  }
}
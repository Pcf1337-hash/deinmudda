import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../utils/platform_helper.dart';
import '../theme/design_tokens.dart';

/// Platform-adaptive App Bar that automatically uses appropriate styling
class PlatformAdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final double? elevation;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const PlatformAdaptiveAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
    this.elevation,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (PlatformHelper.isIOS) {
      return CupertinoNavigationBar(
        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: foregroundColor ?? theme.appBarTheme.foregroundColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: (foregroundColor ?? theme.appBarTheme.foregroundColor)?.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        leading: leading,
        trailing: actions != null ? Row(
          mainAxisSize: MainAxisSize.min,
          children: actions!,
        ) : null,
        backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    } else {
      return AppBar(
        title: Column(
          crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(title),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: (foregroundColor ?? theme.appBarTheme.foregroundColor)?.withOpacity(0.7),
                ),
              ),
          ],
        ),
        leading: leading,
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
        foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
        centerTitle: centerTitle,
        elevation: elevation ?? PlatformHelper.getPlatformElevation(),
        systemOverlayStyle: systemOverlayStyle,
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(PlatformHelper.isIOS ? 44.0 : 56.0);
}

/// Platform-adaptive Button that uses appropriate styling
class PlatformAdaptiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final bool isDestructive;

  const PlatformAdaptiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (PlatformHelper.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        color: isDestructive ? CupertinoColors.destructiveRed : backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? CupertinoColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? theme.colorScheme.error : backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation ?? PlatformHelper.getPlatformElevation(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: child,
      );
    }
  }
}

/// Platform-adaptive Switch with consistent behavior
class PlatformAdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const PlatformAdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformHelper.getPlatformSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
    );
  }
}

/// Platform-adaptive Slider with consistent behavior
class PlatformAdaptiveSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;
  final Color? inactiveColor;

  const PlatformAdaptiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformHelper.getPlatformSlider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
    );
  }
}

/// Platform-adaptive Loading Indicator
class PlatformAdaptiveLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const PlatformAdaptiveLoadingIndicator({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return CupertinoActivityIndicator(
        color: color,
        radius: size != null ? size! / 2 : 10,
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2.0,
        ),
      );
    }
  }
}

/// Platform-adaptive Modal Bottom Sheet
class PlatformAdaptiveModalBottomSheet extends StatelessWidget {
  final Widget child;
  final bool useRootNavigator;
  final bool isDismissible;
  final Color? backgroundColor;
  final double? borderRadius;

  const PlatformAdaptiveModalBottomSheet({
    super.key,
    required this.child,
    this.useRootNavigator = true,
    this.isDismissible = true,
    this.backgroundColor,
    this.borderRadius,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool useRootNavigator = true,
    bool isDismissible = true,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        builder: (context) => PlatformAdaptiveModalBottomSheet(
          useRootNavigator: useRootNavigator,
          isDismissible: isDismissible,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          child: child,
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        isDismissible: isDismissible,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PlatformAdaptiveModalBottomSheet(
          useRootNavigator: useRootNavigator,
          isDismissible: isDismissible,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          child: child,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    if (PlatformHelper.isIOS) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius ?? 12.0),
          ),
        ),
        child: SafeArea(
          child: child,
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius ?? 16.0),
          ),
        ),
        child: SafeArea(
          child: child,
        ),
      );
    }
  }
}

/// Platform-adaptive Dialog
class PlatformAdaptiveDialog extends StatelessWidget {
  final String title;
  final String? content;
  final List<Widget> actions;
  final bool barrierDismissible;

  const PlatformAdaptiveDialog({
    super.key,
    required this.title,
    this.content,
    required this.actions,
    this.barrierDismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    required List<Widget> actions,
    bool barrierDismissible = true,
  }) {
    return PlatformHelper.showPlatformDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      child: PlatformAdaptiveDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: content != null ? Text(content!) : null,
        actions: actions,
      );
    } else {
      return AlertDialog(
        title: Text(title),
        content: content != null ? Text(content!) : null,
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      );
    }
  }
}

/// Platform-adaptive List Tile
class PlatformAdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isThreeLine;

  const PlatformAdaptiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return CupertinoListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      );
    } else {
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        isThreeLine: isThreeLine,
      );
    }
  }
}

/// Platform-adaptive Text Field
class PlatformAdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final Widget? prefix;
  final Widget? suffix;
  final Color? backgroundColor;
  final Color? borderColor;

  const PlatformAdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.prefix,
    this.suffix,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: enabled,
        prefix: prefix,
        suffix: suffix,
        decoration: BoxDecoration(
          color: backgroundColor ?? CupertinoColors.systemFill,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: borderColor ?? CupertinoColors.systemGrey4,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
      );
    } else {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: prefix,
          suffixIcon: suffix,
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: borderColor ?? Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: enabled,
      );
    }
  }
}
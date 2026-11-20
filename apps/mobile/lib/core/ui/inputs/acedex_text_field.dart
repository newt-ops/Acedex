import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/app_colors.dart';

/// Apple-Style Smooth Squircle Text Field
///
/// Implemented directly via [OutlineInputBorder] and Material 3 [InputDecoration]
/// so the fill, border curvature, and prefix/suffix icons are unified in a single
/// render pass with zero clipping artifacts or sharp inner fills.
class AcedexTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final double borderRadius;

  const AcedexTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.borderRadius = 20.0,
  });

  @override
  State<AcedexTextField> createState() => _AcedexTextFieldState();
}

class _AcedexTextFieldState extends State<AcedexTextField> {
  late bool _obscureText;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color accent =
        isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final Color errorColor = isDark ? AppColors.darkError : AppColors.error;
    final Color textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final Color subtextColor =
        isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final squircleBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: line, width: 1.2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          decoration: InputDecoration(
            isDense: false,
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 16.0,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: subtextColor.withValues(alpha: 0.7),
            ),
            border: squircleBorder,
            enabledBorder: squircleBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: accent, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: errorColor, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: errorColor, width: 1.8),
            ),
            prefixIcon: widget.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: _isFocused ? accent : subtextColor,
                      size: 20,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                      child: widget.prefixIcon,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: HugeIcon(
                      icon: _obscureText
                          ? HugeIcons.strokeRoundedViewOffSlash
                          : HugeIcons.strokeRoundedView,
                      size: 20,
                      color: subtextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

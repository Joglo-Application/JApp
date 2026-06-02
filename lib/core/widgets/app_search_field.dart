import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A search-specific text field with a leading search icon and
/// an animated clear button that appears when the field is non-empty.
///
/// Manages its own [FocusNode]. Pass [controller] when you need to
/// read or programmatically set the value.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    widget.onChanged?.call(_controller.text);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        prefixIcon: const Icon(
          Icons.search_outlined,
          size: 20,
          color: AppColors.onSurfaceVariant,
        ),
        suffixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _hasText
              ? IconButton(
                  key: const ValueKey('clear'),
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.onSurfaceVariant,
                  onPressed: _clear,
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.xs,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.xs,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.xs,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

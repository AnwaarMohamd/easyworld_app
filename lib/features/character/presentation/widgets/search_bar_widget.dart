import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/character_cubit.dart';

class SearchBarWidget extends StatefulWidget {
  final VoidCallback? onFilterPressed;
  final bool hasActiveFilters;

  const SearchBarWidget({
    super.key,
    this.onFilterPressed,
    this.hasActiveFilters = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_updateClearButton);
  }

  void _updateClearButton() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    context.read<CharacterCubit>().search('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.lightTextSecondary,
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _hasText
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : Colors.white,
            ),
            onChanged: (value) {
              context.read<CharacterCubit>().search(value);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (widget.onFilterPressed != null)
          IconButton.filled(
            onPressed: widget.onFilterPressed,
            icon: Icon(
              Icons.filter_list_rounded,
              color: widget.hasActiveFilters ? AppColors.primary : null,
            ),
            tooltip: 'Filters',
          ),
      ],
    );
  }
}

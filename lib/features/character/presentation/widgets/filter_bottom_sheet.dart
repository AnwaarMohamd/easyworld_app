import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialStatus;
  final String? initialGender;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const FilterBottomSheet({
    super.key,
    this.initialStatus,
    this.initialGender,
    required this.onStatusChanged,
    required this.onGenderChanged,
    required this.onClear,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedStatus;
  late String? _selectedGender;

  final List<String> _statusOptions = ['Alive', 'Dead', 'unknown'];
  final List<String> _genderOptions = ['Female', 'Male', 'Genderless', 'unknown'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedGender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Filters',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildStatusFilter(),
              const SizedBox(height: AppSpacing.lg),
              _buildGenderFilter(),
              const SizedBox(height: AppSpacing.xxl),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _statusOptions
              .map((status) => _buildFilterChip(
                    label: status,
                    isSelected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _genderOptions
              .map((gender) => _buildFilterChip(
                    label: gender,
                    isSelected: _selectedGender == gender,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGender = selected ? gender : null;
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.primary : null,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final hasFilters = _selectedStatus != null || _selectedGender != null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedGender = null;
              });
              widget.onClear();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: const Text('Clear'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: hasFilters
                ? () {
                    widget.onStatusChanged(_selectedStatus);
                    widget.onGenderChanged(_selectedGender);
                    widget.onApply();
                    Navigator.pop(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }
}

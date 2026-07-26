import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/excel_export_service.dart';
import '../cubit/character_cubit.dart';
import '../cubit/character_state.dart';
import '../widgets/character_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_loading.dart';
import 'character_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CharacterCubit>()..getCharacters(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Pagination scroll
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<CharacterCubit>().getCharacters();
    }

    // Show/hide scroll-to-top FAB
    if (_scrollController.offset > 400) {
      if (!_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      }
    } else {
      if (_showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onRefresh() async {
    await context.read<CharacterCubit>().getCharacters(isRefresh: true);
  }

  void _showFilterSheet(BuildContext context, CharacterState state) {
    final cubit = context.read<CharacterCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: FilterBottomSheet(
          initialStatus: state.statusFilter,
          initialGender: state.genderFilter,
          onApply: (status, gender) {
            cubit.applyFilters(status, gender);
          },
          onClear: () {
            cubit.clearFilters();
          },
        ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<CharacterCubit>();
    
    // Show confirmation dialog
    final shouldExport = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.download_rounded, size: 48, color: AppColors.primary),
        title: Text(
          'Export to Excel',
          style: AppTextStyles.title,
        ),
        content: Text(
          'Export all characters to Excel? This may take a few seconds.',
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Export',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );

    if (shouldExport != true) return;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Exporting characters...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Fetch all characters from all pages
      final allCharacters = await cubit.getAllCharactersForExport();
      
      // Export to Excel
      final filePath = await ExcelExportService.exportCharactersToExcel(allCharacters);
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (filePath != null && mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
            title: Text(
              'Export Successful',
              style: AppTextStyles.title,
            ),
            content: Text(
              'Your Excel file has been generated successfully.',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Export failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rick & Morty',
          style: AppTextStyles.headingLarge.copyWith(
            color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          BlocBuilder<CharacterCubit, CharacterState>(
            builder: (context, state) {
              if (state.characters.isNotEmpty) {
                return IconButton(
                  onPressed: _exportToExcel,
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Export to Excel',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // SearchBar always visible
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: BlocBuilder<CharacterCubit, CharacterState>(
              builder: (context, state) {
                final hasFilters = state.statusFilter != null || state.genderFilter != null;
                return SearchBarWidget(
                  onFilterPressed: () => _showFilterSheet(context, state),
                  hasActiveFilters: hasFilters,
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CharacterCubit, CharacterState>(
              builder: (context, state) {
                // Loading state with no data
                if (state.status == CharacterStatus.loading &&
                    state.characters.isEmpty) {
                  return const ShimmerLoading();
                }

                // Failure state with no data
                if (state.status == CharacterStatus.failure &&
                    state.characters.isEmpty) {
                  return ErrorStateWidget(
                    message: state.errorMessage ?? 'Something went wrong',
                    onRetry: () =>
                        context.read<CharacterCubit>().getCharacters(isRefresh: true),
                  );
                }

                // Empty state (search or filter returned no results)
                if (state.characters.isEmpty && state.status != CharacterStatus.loading) {
                  final isSearchActive = state.search.isNotEmpty;
                  return EmptyStateWidget(
                    title: 'No characters found',
                    message: isSearchActive ? 'Try another search keyword.' : 'No characters available',
                    icon: isSearchActive ? Icons.search_off : Icons.filter_list,
                    showClearSearch: isSearchActive,
                    onRetry: () => context.read<CharacterCubit>().clearSearch(),
                  );
                }

                // Success state with data
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Error banner during pagination
                      if (state.errorMessage != null &&
                          state.errorMessage!.isNotEmpty &&
                          state.characters.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: _buildErrorBanner(context, state),
                          ),
                        ),
                      // Character list
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Loading indicator at the end
                              if (index >= state.characters.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                  ),
                                  child: state.isLoadingMore
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : const SizedBox.shrink(),
                                );
                              }

                              final character = state.characters[index];
                              return CharacterCard(
                                character: character,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CharacterDetailsPage(character: character),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: state.characters.length +
                                (state.hasReachedMax ? 0 : 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              mini: true,
              onPressed: _scrollToTop,
              tooltip: 'Scroll to top',
              child: const Icon(Icons.arrow_upward_rounded),
            )
          : null,
    );
  }

  Widget _buildErrorBanner(BuildContext context, CharacterState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.error, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.errorMessage ?? 'Error loading more',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                if (state.canRetry) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: () =>
                        context.read<CharacterCubit>().retryLastPage(),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
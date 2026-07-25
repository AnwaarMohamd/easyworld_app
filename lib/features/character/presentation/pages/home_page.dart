import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/excel_export_service.dart';
import '../../data/models/character_model.dart';
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
      builder: (_) => FilterBottomSheet(
        initialStatus: state.statusFilter,
        initialGender: state.genderFilter,
        onStatusChanged: (status) {
          cubit.setStatusFilter(status);
          Navigator.pop(context);
        },
        onGenderChanged: (gender) {
          cubit.setGenderFilter(gender);
          Navigator.pop(context);
        },
        onClear: () {
          cubit.clearFilters();
          Navigator.pop(context);
        },
        onApply: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _exportToExcel(List<CharacterModel> characters) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final filePath = await ExcelExportService.exportCharactersToExcel(characters);
      if (filePath != null) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Characters exported successfully.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // File open functionality can be added here if needed
                // For now, just show that the action was triggered
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('File saved to your documents folder'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Export failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rick & Morty', style: AppTextStyles.headingLarge),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          BlocBuilder<CharacterCubit, CharacterState>(
            builder: (context, state) {
              final hasFilters = state.statusFilter != null || state.genderFilter != null;
              return Row(
                children: [
                  IconButton(
                    onPressed: () => _showFilterSheet(context, state),
                    icon: Badge(
                      isLabelVisible: hasFilters,
                      label: const Text('1'),
                      child: const Icon(Icons.filter_list_rounded),
                    ),
                    tooltip: 'Filters',
                  ),
                  if (state.characters.isNotEmpty)
                    IconButton(
                      onPressed: () => _exportToExcel(state.characters),
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Export to Excel',
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CharacterCubit, CharacterState>(
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
            return EmptyStateWidget(
              title: 'No Characters Found',
              message: state.hasActiveFilters
                  ? 'Try adjusting your search or filters'
                  : 'No characters available',
              icon: state.hasActiveFilters ? Icons.filter_list : Icons.search_off,
              onRetry: state.hasActiveFilters
                  ? () => context.read<CharacterCubit>().clearFilters()
                  : null,
              retryLabel: state.hasActiveFilters ? 'Clear Filters' : null,
            );
          }

          // Success state with data
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: const SearchBarWidget(),
                      ),
                    ),
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
              ),
              // Scroll-to-top FAB
              if (_showScrollToTop)
                Positioned(
                  bottom: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _scrollToTop,
                    tooltip: 'Scroll to top',
                    child: const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
            ],
          );
        },
      ),
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

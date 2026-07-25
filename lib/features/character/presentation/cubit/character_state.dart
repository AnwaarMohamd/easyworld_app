import 'package:equatable/equatable.dart';

import '../../data/models/character_model.dart';

enum CharacterStatus {
  initial,
  loading,
  success,
  failure,
}

class CharacterState extends Equatable {
  final CharacterStatus status;
  final List<CharacterModel> characters;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final String search;
  final String? statusFilter;
  final String? genderFilter;
  final bool isLoadingMore;
  final bool canRetry;

  const CharacterState({
    this.status = CharacterStatus.initial,
    this.characters = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.search = '',
    this.statusFilter,
    this.genderFilter,
    this.isLoadingMore = false,
    this.canRetry = false,
  });

  bool get hasActiveFilters => search.isNotEmpty || statusFilter != null || genderFilter != null;

  CharacterState copyWith({
    CharacterStatus? status,
    List<CharacterModel>? characters,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    String? search,
    String? statusFilter,
    String? genderFilter,
    bool? isLoadingMore,
    bool? canRetry,
  }) {
    return CharacterState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      genderFilter: genderFilter ?? this.genderFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      canRetry: canRetry ?? this.canRetry,
    );
  }

  @override
  List<Object?> get props => [
        status,
        characters,
        errorMessage,
        currentPage,
        hasReachedMax,
        search,
        statusFilter,
        genderFilter,
        isLoadingMore,
        canRetry,
      ];
}
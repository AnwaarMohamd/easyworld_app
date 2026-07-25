import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/character_repository.dart';
import 'character_state.dart';

class CharacterCubit extends Cubit<CharacterState> {
  CharacterCubit(this._repository) : super(const CharacterState());

  final CharacterRepository _repository;
  bool _isLoading = false;
  int _requestId = 0;
  int _lastSuccessfulRequestId = -1;
  Timer? _searchDebounce;
  CancelToken? _currentCancelToken;

  Future<void> getCharacters({
    bool isRefresh = false,
    bool isRetry = false,
  }) async {
    // Prevent concurrent requests during pagination
    if (_isLoading && !isRetry) return;
    
    // Don't request if max reached and not refreshing/retrying
    if (state.hasReachedMax && !isRefresh && !isRetry) return;

    // Cancel previous request if making a new one
    if (isRefresh || isRetry) {
      _currentCancelToken?.cancel('Cancelled by new request');
      _currentCancelToken = CancelToken();
    } else {
      _currentCancelToken ??= CancelToken();
    }

    _isLoading = true;
    final currentRequestId = ++_requestId;
    
    try {
      // Only show loading state on initial load or refresh
      if (state.characters.isEmpty || isRefresh) {
        emit(state.copyWith(status: CharacterStatus.loading));
      } else {
        emit(state.copyWith(isLoadingMore: true));
      }

      final response = await _repository.getCharacters(
        page: isRefresh ? 1 : state.currentPage,
        name: state.search.isEmpty ? null : state.search,
        status: state.statusFilter,
        gender: state.genderFilter,
        cancelToken: _currentCancelToken,
      );

      // Ignore outdated responses
      if (currentRequestId <= _lastSuccessfulRequestId) return;
      _lastSuccessfulRequestId = currentRequestId;

      final characters = isRefresh
          ? response.characters
          : [...state.characters, ...response.characters];

      emit(
        state.copyWith(
          status: CharacterStatus.success,
          characters: characters,
          currentPage: isRefresh ? 2 : state.currentPage + 1,
          hasReachedMax: !response.hasNextPage,
          isLoadingMore: false,
          canRetry: false,
          errorMessage: null,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      
      final errorMessage = _parseErrorMessage(e);
      final hasData = state.characters.isNotEmpty;
      
      emit(
        state.copyWith(
          status: hasData ? CharacterStatus.success : CharacterStatus.failure,
          errorMessage: errorMessage,
          isLoadingMore: false,
          canRetry: true,
        ),
      );
    } catch (e) {
      final errorMessage = _parseErrorMessage(e);
      final hasData = state.characters.isNotEmpty;
      
      emit(
        state.copyWith(
          status: hasData ? CharacterStatus.success : CharacterStatus.failure,
          errorMessage: errorMessage,
          isLoadingMore: false,
          canRetry: true,
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> search(String value) async {
    _searchDebounce?.cancel();

    emit(
      state.copyWith(
        search: value,
        currentPage: 1,
        hasReachedMax: false,
        errorMessage: null,
      ),
    );

    if (value.isEmpty) {
      _searchDebounce = Timer(
        const Duration(milliseconds: 300),
        () => getCharacters(isRefresh: true),
      );
    } else {
      _searchDebounce = Timer(
        const Duration(milliseconds: 500),
        () => getCharacters(isRefresh: true),
      );
    }
  }

  void setStatusFilter(String? status) async {
    _currentCancelToken?.cancel('Filter changed');
    _currentCancelToken = CancelToken();
    
    emit(
      state.copyWith(
        statusFilter: status,
        currentPage: 1,
        hasReachedMax: false,
        characters: [],
        errorMessage: null,
      ),
    );
    
    await getCharacters(isRefresh: true);
  }

  void setGenderFilter(String? gender) async {
    _currentCancelToken?.cancel('Filter changed');
    _currentCancelToken = CancelToken();
    
    emit(
      state.copyWith(
        genderFilter: gender,
        currentPage: 1,
        hasReachedMax: false,
        characters: [],
        errorMessage: null,
      ),
    );
    
    await getCharacters(isRefresh: true);
  }

  void clearFilters() async {
    _currentCancelToken?.cancel('Filters cleared');
    _currentCancelToken = CancelToken();
    
    emit(
      state.copyWith(
        statusFilter: null,
        genderFilter: null,
        search: '',
        currentPage: 1,
        hasReachedMax: false,
        characters: [],
        errorMessage: null,
      ),
    );
    
    await getCharacters(isRefresh: true);
  }

  Future<void> retryLastPage() => getCharacters(isRetry: true);

  String _parseErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('429')) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (errorString.contains('Connection')) {
      return 'Connection error. Please check your internet connection.';
    } else if (errorString.contains('SocketException')) {
      return 'Network error. Please try again.';
    } else if (errorString.contains('404')) {
      return 'No characters found with these filters.';
    }
    
    return 'Failed to load characters. Please try again.';
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _currentCancelToken?.cancel('Cubit closed');
    return super.close();
  }
}
import 'package:dio/dio.dart';

import '../../data/models/characters_response_model.dart';

abstract class CharacterRepository {
  Future<CharactersResponseModel> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? gender,
    CancelToken? cancelToken,
  });
}
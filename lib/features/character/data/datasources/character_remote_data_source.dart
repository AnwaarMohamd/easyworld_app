import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/characters_response_model.dart';

class CharacterRemoteDataSource {
  CharacterRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CharactersResponseModel> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? gender,
  }) async {
    final response = await _dio.get(
      ApiConstants.characters,
      queryParameters: {
        'page': page,
        if (name != null && name.isNotEmpty) 'name': name,
        if (status != null) 'status': status,
        if (gender != null) 'gender': gender,
      },
    );

    return CharactersResponseModel.fromJson(response.data);
  }
}
import '../../domain/repositories/character_repository.dart';
import '../datasources/character_remote_data_source.dart';
import '../models/characters_response_model.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  CharacterRepositoryImpl(this._remoteDataSource);

  final CharacterRemoteDataSource _remoteDataSource;

  @override
  Future<CharactersResponseModel> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? gender,
  }) {
    return _remoteDataSource.getCharacters(
      page: page,
      name: name,
      status: status,
      gender: gender,
    );
  }
}
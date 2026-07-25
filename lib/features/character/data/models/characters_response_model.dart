import 'character_model.dart';

class CharactersResponseModel {
  final List<CharacterModel> characters;
  final bool hasNextPage;

  const CharactersResponseModel({
    required this.characters,
    required this.hasNextPage,
  });

  factory CharactersResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CharactersResponseModel(
      characters: (json['results'] as List)
          .map(
            (e) => CharacterModel.fromJson(e),
          )
          .toList(),
      hasNextPage: json['info']['next'] != null,
    );
  }
}
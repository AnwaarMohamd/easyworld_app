import 'package:equatable/equatable.dart';

class CharacterModel extends Equatable {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String origin;
  final String location;
  final int episodeCount;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.episodeCount,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      gender: json['gender'] as String,
      image: json['image'] as String,
      origin: json['origin']['name'] as String,
      location: json['location']['name'] as String,
      episodeCount: (json['episode'] as List).length,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        species,
        gender,
        image,
        origin,
        location,
        episodeCount,
      ];
}
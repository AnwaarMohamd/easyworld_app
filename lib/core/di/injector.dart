import 'package:dio/dio.dart';
import 'package:eazyworld_app/features/character/data/datasources/character_remote_data_source.dart';
import 'package:eazyworld_app/features/character/data/repositories/character_repository_impl.dart';
import 'package:eazyworld_app/features/character/domain/repositories/character_repository.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  sl.registerLazySingleton<Dio>(DioClient.create);

  sl.registerLazySingleton(NetworkInfo.new);

  sl.registerLazySingleton<Dio>(DioClient.create);

  sl.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(sl()),
  );
}

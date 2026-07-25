import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  sl.registerLazySingleton<Dio>(
    DioClient.create,
  );

  sl.registerLazySingleton(
    NetworkInfo.new,
  );
}
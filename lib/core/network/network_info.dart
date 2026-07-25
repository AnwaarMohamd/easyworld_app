import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkInfo {
  const NetworkInfo();

  Future<bool> get isConnected async {
    return InternetConnection().hasInternetAccess;
  }
}
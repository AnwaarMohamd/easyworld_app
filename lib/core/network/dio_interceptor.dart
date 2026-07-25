import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '''
🌍 REQUEST
METHOD: ${options.method}
URL: ${options.uri}
QUERY: ${options.queryParameters}
''',
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '''
✅ RESPONSE
STATUS: ${response.statusCode}
URL: ${response.requestOptions.uri}
''',
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '''
❌ ERROR

${err.message}
''',
      );
    }

    super.onError(err, handler);
  }
}
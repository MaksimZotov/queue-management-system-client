import 'package:dio/dio.dart';
import 'package:queue_management_system_client/data/converters/account/tokens_converter.dart';

import '../../../domain/models/account/tokens_model.dart';
import '../../local/secure_storage.dart';
import '../server_api.dart';

class InterceptorsWrapperServerApi extends InterceptorsWrapper {

  final SecureStorage _secureStorage;
  final Dio _dioApi;

  InterceptorsWrapperServerApi(
      this._secureStorage,
      this._dioApi
  );

  static const _refreshTokenMethod = '/account/token/refresh';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = 'application/json';
    String path = options.path;
    if (!path.endsWith(ServerApi.signupMethod) &&
        !path.endsWith(ServerApi.loginMethod) &&
        !path.endsWith(ServerApi.confirmMethod)
    ) {
      options.headers['Authorization'] = 'Bearer ${ await _secureStorage.getAccessToken() }';
    }
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if ((err.response?.statusCode == 401)) {
      if (await _secureStorage.containsRefreshToken()) {
        final refreshToken = await _secureStorage.getRefreshToken();
        final response = await _dioApi.post(
            '${ServerApi.url}$_refreshTokenMethod',
            queryParameters: { 'refresh_token': 'Bearer $refreshToken' }
        );
        int? code = response.statusCode;
        if (code != null && code >= 200 && code < 300) {
          final tokens = TokensConverter(TokensFields()).fromJson(response.data!);
          await _secureStorage.setAccessToken(accessToken: tokens.access);
          await _secureStorage.setRefreshToken(refreshToken: tokens.refresh);
          await _secureStorage.setUsername(username: tokens.username);
          final requestOptions = err.requestOptions;
          final options = Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          );
          final retryResponse = await _dioApi.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: options
          );
          return handler.resolve(retryResponse);
        } else {
          await _secureStorage.deleteAll();
        }
      }
    }
    return handler.next(err);
  }
}
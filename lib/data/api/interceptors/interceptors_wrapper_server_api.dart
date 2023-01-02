import 'package:dio/dio.dart';

import '../../../domain/models/verification/tokens.dart';
import '../../local/secure_storage.dart';
import '../server_api.dart';

class InterceptorsWrapperServerApi extends InterceptorsWrapper {

  final SecureStorage _tokensStorage;
  final Dio _dioApi;

  InterceptorsWrapperServerApi(
      this._tokensStorage,
      this._dioApi
  );

  static const _refreshTokenMethod = '/verification/token/refresh';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = 'application/json';
    String path = options.path;
    if (!path.endsWith(ServerApi.signupMethod) &&
        !path.endsWith(ServerApi.loginMethod) &&
        !path.endsWith(ServerApi.confirmMethod)
    ) {
      options.headers['Authorization'] = 'Bearer ${ await _tokensStorage.getAccessToken() }';
    }
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if ((err.response?.statusCode == 401)) {
      if (await _tokensStorage.containsRefreshToken()) {
        final refreshToken = await _tokensStorage.getRefreshToken();
        final response = await _dioApi.post<TokensModel>(
            _refreshTokenMethod,
            queryParameters: { 'refresh_token': refreshToken }
        );
        int? code = response.statusCode;
        if (code != null && code >= 200 && code < 300) {
          final tokens = response.data!;
          await _tokensStorage.setAccessToken(accessToken: tokens.access);
          await _tokensStorage.setRefreshToken(refreshToken: tokens.refresh);
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
          await _tokensStorage.deleteAll();
        }
      }
    }
    return handler.next(err);
  }
}
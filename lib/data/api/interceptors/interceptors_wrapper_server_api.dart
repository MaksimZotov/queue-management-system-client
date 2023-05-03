import 'package:dio/dio.dart';

import '../../../domain/models/account/tokens_model.dart';
import '../../local/account_storage.dart';
import '../server_api.dart';

class InterceptorsWrapperServerApi extends InterceptorsWrapper {

  final AccountInfoStorage _accountInfoStorage;
  final Dio _dioApi;

  InterceptorsWrapperServerApi(
      this._accountInfoStorage,
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
      options.headers['Authorization'] = 'Bearer ${ await _accountInfoStorage.getAccessToken() }';
    }
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if ((err.response?.statusCode == 401)) {
      if (await _accountInfoStorage.containsRefreshToken()) {
        final refreshToken = await _accountInfoStorage.getRefreshToken();
        final response = await _dioApi.post(
            '${ServerApi.url}$_refreshTokenMethod',
            queryParameters: { 'refresh_token': 'Bearer $refreshToken' }
        );
        int? code = response.statusCode;
        if (code != null && code >= 200 && code < 300) {
          final tokens = TokensModel.fromJson(response.data!);
          await _accountInfoStorage.setAccessToken(accessToken: tokens.access);
          await _accountInfoStorage.setRefreshToken(refreshToken: tokens.refresh);
          await _accountInfoStorage.setAccountId(accountId: tokens.accountId);
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
          await _accountInfoStorage.deleteAll();
        }
      }
    }
    return handler.next(err);
  }
}
import 'package:dio/dio.dart';
import 'package:dio_logging_interceptor/dio_logging_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/api/interceptors/interceptors_wrapper_server_api.dart';
import 'package:queue_management_system_client/data/local/tokens_storage.dart';

@module
abstract class DataModule {

  @lazySingleton
  Dio provideDioApi(TokensStorage tokensStorage) {
    Dio dioApi = Dio();
    dioApi.interceptors.addAll(
        [
          InterceptorsWrapperServerApi(tokensStorage, dioApi),
          DioLoggingInterceptor(
            level: Level.body,
            compact: false
          )
        ]
    );
    dioApi.options.connectTimeout = 5000;
    dioApi.options.receiveTimeout = 5000;
    dioApi.options.sendTimeout = 5000;
    return dioApi;
  }
}
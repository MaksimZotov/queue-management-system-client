import 'package:dio/dio.dart';
import 'package:dio_logging_interceptor/dio_logging_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/api/interceptors/interceptors_wrapper_server_api.dart';
import 'package:queue_management_system_client/data/local/secure_storage.dart';

@module
abstract class DataModule {

  @lazySingleton
  Dio provideDioApi(SecureStorage tokensStorage) {
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
    return dioApi;
  }
}
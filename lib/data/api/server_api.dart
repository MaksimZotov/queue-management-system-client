import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/verification/confirm_converter.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/domain/models/verification/Confirm.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/queue/queue.dart';
import '../../domain/models/verification/login.dart';
import '../../domain/models/verification/signup.dart';
import '../../domain/models/verification/tokens.dart';
import '../converters/base/container_for_list_converter.dart';
import '../converters/base/error_result_converter.dart';
import '../converters/json_converter.dart';
import '../converters/location/location.dart';
import '../converters/queue/queue.dart';
import '../converters/verification/login_converter.dart';
import '../converters/verification/signup_converters.dart';
import '../converters/verification/tokens_converter.dart';
import '../local/tokens_storage.dart';

@lazySingleton
class ServerApi {
  final String unknownError = 'Неизвестная ошибка';
  final String responseTimeoutError = 'Вышло время ожидания ответа';
  final String noConnectionError = 'Нет соединения';

  static const url = 'http://localhost:8080';

  static const signupMethod = '/verification/signup';
  static const confirmMethod = '/verification/confirm';
  static const loginMethod = '/verification/login';

  final Dio _dioApi;
  final TokensStorage _tokensStorage;

  final ErrorResultConverter _errorResultConverter;
  final ContainerForListConverter _containerForListConverter;

  final TokensConverter _tokensConverter;
  final SignupConverter _signupConverter;
  final ConfirmConverter _confirmConverter;
  final LoginConverter _loginConverter;

  final LocationConverter _locationConverter;

  final QueueConverter _queueConverter;

  ServerApi(
      this._dioApi,
      this._tokensStorage,
      this._errorResultConverter,
      this._containerForListConverter,
      this._tokensConverter,
      this._signupConverter,
      this._confirmConverter,
      this._loginConverter,
      this._locationConverter,
      this._queueConverter
  );

  Future<Result<ContainerForList<T>>> _execRequestForList<T>({
    JsonConverter<T>? converter,
    required Future<Response> request
  }) async {
    try {
      Response response = await request;
      int? code = response.statusCode;
      if (code != null && code >= 200 && code < 300) {
        return SuccessResult(
            data: _containerForListConverter.fromJson<T>(
                json: response.data,
                converter: converter!
            )
        );
      } else {
        return getErrorFromResponse(response);
      }
    } on Exception catch(exception) {
      return getErrorFromException(exception);
    }
  }

  Future<Result<T>> _execRequest<T>({
    JsonConverter? converter,
    required Future<Response> request
  }) async {
    try {
      Response response = await request;
      int? code = response.statusCode;
      if (code != null && code >= 200 && code < 300) {
        return SuccessResult(data: converter?.fromJson(response.data));
      } else {
        return getErrorFromResponse(response);
      }
    } on Exception catch(exception) {
      return getErrorFromException(exception);
    }
  }

  ErrorResult<T> getErrorFromResponse<T>(Response response) {
    final ErrorResult error = _errorResultConverter.fromJson(
        response.data
    );
    return ErrorResult(
        description: error.description ?? unknownError,
        errors: error.errors
    );
  }

  ErrorResult<T> getErrorFromException<T>(Exception exception) {
    if (exception is TimeoutException) {
      return ErrorResult(description: responseTimeoutError);
    } else if (exception is SocketException) {
      if (exception.osError?.errorCode == 101) {
        return ErrorResult(description: noConnectionError);
      } else {
        return ErrorResult(description: unknownError);
      }
    } else {
      return ErrorResult(description: unknownError);
    }
  }

  Future<void> _saveTokens(SuccessResult<TokensModel> result) async {
    final tokens = (result).data;
    await _tokensStorage.setAccessToken(accessToken: tokens.access);
    await _tokensStorage.setRefreshToken(refreshToken: tokens.refresh);
  }





  Future<Result> signup(SignupModel signup) async {
    final result = await _execRequest(
        request: _dioApi.post(
          '$url$signupMethod',
          data: _signupConverter.toJson(signup)
        )
    );
    return result;
  }

  Future<Result> confirm(ConfirmModel confirm) async {
    final result = await _execRequest(
        request: _dioApi.post(
            '$url$confirmMethod',
            data: _confirmConverter.toJson(confirm)
        )
    );
    return result;
  }

  Future<Result<TokensModel>> login(LoginModel login) async {
    final result = await _execRequest<TokensModel>(
        converter: _tokensConverter,
        request: _dioApi.post(
            '$url$loginMethod',
            data: _loginConverter.toJson(login)
        )
    );
    if (result is SuccessResult) {
      await _saveTokens(result as SuccessResult<TokensModel>);
    }
    return result;
  }





  Future<Result<ContainerForList<LocationModel>>> getMyLocations(int page, int pageSize) async {
    return await _execRequestForList(
        converter: _locationConverter,
        request: _dioApi.get(
          '$url/locations/me',
          queryParameters: {
            'page': page,
            'page_size': pageSize
          }
        )
    );
  }

  Future<Result<LocationModel>> createLocation(LocationModel location) async {
    return await _execRequest(
        converter: _locationConverter,
        request: _dioApi.post(
            '$url/locations/create',
             data: _locationConverter.toJson(location)
        )
    );
  }

  Future<Result> deleteLocation(int id) async {
    return await _execRequest(
        converter: null,
        request: _dioApi.delete(
          '$url/locations/$id/delete',
        )
    );
  }




  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize) async {
    return await _execRequestForList(
        converter: _queueConverter,
        request: _dioApi.get(
            '$url/queues',
            queryParameters: {
              'location_id': locationId,
              'page': page,
              'page_size': pageSize
            }
        )
    );
  }

  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue) async {
    return await _execRequest(
        converter: _queueConverter,
        request: _dioApi.post(
            '$url/queues/create',
            data: _queueConverter.toJson(queue),
            queryParameters: {
              'location_id': locationId
            }
        )
    );
  }

  Future<Result> deleteQueue(int id) async {
    return await _execRequest(
        converter: null,
        request: _dioApi.delete(
          '$url/queues/$id/delete',
        )
    );
  }

  Future<Result<QueueModel>> getQueueState(int id) async {
    return await _execRequest(
        converter: _queueConverter,
        request: _dioApi.get(
            '$url/queues/$id'
        )
    );
  }

  Future<Result> serveClientInQueue(int queueId, int clientId) async {
    return await _execRequest(
        request: _dioApi.post(
            '$url/queues/$queueId/clients/$clientId/serve'
        )
    );
  }

  Future<Result> notifyClientInQueue(int queueId, int clientId) async {
    return await _execRequest(
        request: _dioApi.post(
            '$url/queues/$queueId/clients/$clientId/notify'
        )
    );
  }
}
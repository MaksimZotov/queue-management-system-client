import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/board/board_model_converter.dart';
import 'package:queue_management_system_client/data/converters/client/client_converter.dart';
import 'package:queue_management_system_client/data/converters/client/client_join_info_converter.dart';
import 'package:queue_management_system_client/data/converters/location/has_rights_converter.dart';
import 'package:queue_management_system_client/data/converters/queue/client_in_queue_converter.dart';
import 'package:queue_management_system_client/data/converters/account/confirm_converter.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/board/board_model.dart';
import 'package:queue_management_system_client/domain/models/client/client_model.dart';
import 'package:queue_management_system_client/domain/models/location/has_rights_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';
import 'package:queue_management_system_client/domain/models/account/confirm_model.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/client/client_join_info_model.dart';
import '../../domain/models/queue/add_client_info.dart';
import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/account/login_model.dart';
import '../../domain/models/account/signup_model.dart';
import '../../domain/models/account/tokens_model.dart';
import '../converters/base/container_for_list_converter.dart';
import '../converters/base/error_result_converter.dart';
import '../converters/json_converter.dart';
import '../converters/location/location_converter.dart';
import '../converters/queue/add_client_info_converter.dart';
import '../converters/queue/queue_converter.dart';
import '../converters/rights/rights_converter.dart';
import '../converters/account/login_converter.dart';
import '../converters/account/signup_converters.dart';
import '../converters/account/tokens_converter.dart';
import '../local/secure_storage.dart';

@singleton
class ServerApi {
  final String unknownError = 'Неизвестная ошибка';
  final String serverError = 'Ошибка на сервере';
  final String responseTimeoutError = 'Вышло время ожидания ответа';
  final String noConnectionError = 'Нет соединения';

  static const url = 'http://localhost:8080';
  static const clientUrl = 'http://localhost:64407';

  static const signupMethod = '/account/signup';
  static const confirmMethod = '/account/confirm';
  static const loginMethod = '/account/login';

  final Dio _dioApi;
  final SecureStorage _tokensStorage;

  final ErrorResultConverter _errorResultConverter;
  final ContainerForListConverter _containerForListConverter;

  final TokensConverter _tokensConverter;
  final SignupConverter _signupConverter;
  final ConfirmConverter _confirmConverter;
  final LoginConverter _loginConverter;

  final LocationConverter _locationConverter;
  final HasRightsConverter _hasRightsConverter;

  final QueueConverter _queueConverter;
  final ClientInQueueConverter _clientInQueueConverter;
  final AddClientInfoConverter _addClientInfoConverter;

  final ClientConverter _clientConverter;
  final ClientJoinInfoConverter _clientJoinInfoConverter;

  final RightsConverter _rightsConverter;

  final BoardConverter _boardConverter;

  Map<String, StompClient> stompClients = {};
  final socketUrl = '$url/our-websocket';

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
      this._hasRightsConverter,

      this._queueConverter,
      this._clientInQueueConverter,
      this._addClientInfoConverter,

      this._clientConverter,
      this._clientJoinInfoConverter,

      this._rightsConverter,

      this._boardConverter
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
    if (response.statusCode == 500) {
      return ErrorResult(description: serverError);
    }
    final ErrorResult error = _errorResultConverter.fromJson(
        response.data
    );
    return ErrorResult(
        description: error.description,
        errors: error.errors
    );
  }

  ErrorResult<T> getErrorFromException<T>(Exception exception) {
    if (exception is DioError) {
      Response? response = exception.response;
      if (response != null) {
        return getErrorFromResponse(response);
      }
    }
    if (exception is TimeoutException) {
      return ErrorResult(description: responseTimeoutError);
    }
    if (exception is SocketException && exception.osError?.errorCode == 101) {
      return ErrorResult(description: noConnectionError);
    }
    return ErrorResult(description: unknownError);
  }

  Future<void> _saveTokens(SuccessResult<TokensModel> result) async {
    final tokens = result.data;
    await _tokensStorage.setAccessToken(accessToken: tokens.access);
    await _tokensStorage.setRefreshToken(refreshToken: tokens.refresh);
    await _tokensStorage.setUsername(username: tokens.username);
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





  Future<Result<ContainerForList<LocationModel>>> getLocations(String username) async {
    return await _execRequestForList(
        converter: _locationConverter,
        request: _dioApi.get(
          '$url/locations',
          queryParameters: {
            'username': username,
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

  Future<Result<LocationModel>> getLocation(int locationId, String? username) async {
    return await _execRequest(
        converter: _locationConverter,
        request: _dioApi.get(
            '$url/locations/$locationId',
            queryParameters: { 'username': username }
        )
    );
  }

  Future<Result> deleteLocation(int locationId) async {
    return await _execRequest(
        converter: null,
        request: _dioApi.delete(
            '$url/locations/$locationId/delete'
        )
    );
  }

  Future<Result<HasRightsModel>> checkHasRights(String username) async {
    return await _execRequest(
        converter: _hasRightsConverter,
        request: _dioApi.get(
            '$url/locations/check',
            queryParameters: { 'username': username }
        )
    );
  }




  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String username) async {
    return await _execRequestForList(
        converter: _queueConverter,
        request: _dioApi.get(
            '$url/queues',
            queryParameters: {
              'username': username,
              'location_id': locationId,
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
            '$url/queues/$queueId/serve',
            queryParameters: { 'client_id': clientId }
        )
    );
  }

  Future<Result> notifyClientInQueue(int queueId, int clientId) async {
    return await _execRequest(
        request: _dioApi.post(
            '$url/queues/$queueId/notify',
            queryParameters: { 'client_id': clientId }
        )
    );
  }

  Future<Result<ClientInQueueModel>> addClientToQueue(int queueId, AddClientInfo addClientInfo) async {
    return await _execRequest(
        converter: _clientInQueueConverter,
        request: _dioApi.post(
            '$url/queues/$queueId/client/add',
            data: _addClientInfoConverter.toJson(addClientInfo)
        )
    );
  }





  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId, String? email, String? accessKey) async {
    return await _execRequest(
        converter: _clientConverter,
        request: _dioApi.get(
            '$url/queues/$queueId/client',
            queryParameters: {
              'email': email,
              'access_key': accessKey
            }
        )
    );
  }

  Future<Result<ClientModel>> joinClientToQueue(String username, int locationId, int queueId, ClientJoinInfo clientJoinInfo) async {
    return await _execRequest(
        converter: _clientConverter,
        request: _dioApi.post(
            '$url/queues/$queueId/client/join',
            data: _clientJoinInfoConverter.toJson(clientJoinInfo),
            queryParameters: {
              'username': username,
              'location_id': locationId,
              'queue_id': queueId
            }
        )
    );
  }

  Future<Result<ClientModel>> rejoinClientToQueue(int queueId, String email) async {
    return await _execRequest(
        converter: _clientConverter,
        request: _dioApi.post(
            '$url/queues/$queueId/client/rejoin',
            queryParameters: { 'email': email}
        )
    );
  }

  Future<Result<ClientModel>> confirmClientCodeInQueue(int queueId, String email, String code) async {
    return await _execRequest(
        converter: _clientConverter,
        request: _dioApi.post(
            '$url/queues/$queueId/client/confirm',
            queryParameters: {
              'email': email,
              'code': code
            }
        )
    );
  }

  Future<Result<ClientModel>> leaveQueue(int queueId, String? email, String? accessKey) async {
    return await _execRequest(
        converter: _clientConverter,
        request: _dioApi.post(
            '$url/queues/$queueId/client/leave',
            queryParameters: {
              'email': email,
              'access_key': accessKey
            }
        )
    );
  }





  void connectToSocket<T>(
      String destination,
      VoidCallback onConnected,
      ValueChanged<T> onQueueChanged,
      ValueChanged<dynamic> onError
  ) {
    if (stompClients.containsKey(destination)) {
      stompClients.remove(destination)?.deactivate();
    }
    StompClient client = StompClient(
        config: StompConfig.SockJS(
          url: socketUrl,
          onConnect: (frame) => _onConnect(destination, onConnected, onQueueChanged),
          onWebSocketError: onError,
        )
    );
    client.activate();
    stompClients[destination] = client;
  }

  void disconnectFromSocket(String destination) {
    stompClients[destination]?.deactivate();
    stompClients.remove(destination);
  }

  void _onConnect<T>(
      String destination,
      VoidCallback onConnected,
      ValueChanged<T> onQueueChanged
  ) {
    onConnected.call();
    stompClients[destination]?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (T == QueueModel) {
          onQueueChanged.call(_queueConverter.fromJson(json.decode(frame.body!)) as T);
        } else if (T == BoardModel) {
          onQueueChanged.call(_boardConverter.fromJson(json.decode(frame.body!)) as T);
        }
      }
    );
  }





  Future<Result> addRights(int locationId, String email) {
    return _execRequest(
        request: _dioApi.post(
            '$url/rights/add',
            queryParameters: {
              'location_id': locationId,
              'email': email
            }
        )
    );
  }

  Future<Result> deleteRights(int locationId, String email) {
    return _execRequest(
        request: _dioApi.delete(
            '$url/rights/delete',
            queryParameters: {
              'location_id': locationId,
              'email': email
            }
        )
    );
  }

  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId) {
    return _execRequestForList(
        converter: _rightsConverter,
        request: _dioApi.get(
            '$url/rights',
            queryParameters: {
              'location_id': locationId
            }
        )
    );
  }





  Future<Result<BoardModel>> getBoard(int locationId) {
    return _execRequest(
        converter: _boardConverter,
        request: _dioApi.get(
            '$url/board',
            queryParameters: {
              'location_id': locationId,
            }
        )
    );
  }
}
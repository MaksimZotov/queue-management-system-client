import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
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
import '../../domain/models/client/client_join_info.dart';
import '../../domain/models/queue/add_client_info.dart';
import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/account/login_model.dart';
import '../../domain/models/account/signup_model.dart';
import '../../domain/models/account/tokens_model.dart';
import '../converters/container_for_list_converter.dart';
import '../converters/from_json.dart';
import '../local/secure_storage.dart';

@singleton
class ServerApi {

  static const url = 'http://localhost:8080';
  static const clientUrl = 'http://localhost:64407';

  static const signupMethod = '/account/signup';
  static const confirmMethod = '/account/confirm';
  static const loginMethod = '/account/login';

  final Dio _dioApi;
  final SecureStorage _tokensStorage;
  final ContainerForListConverter _containerForListConverter;

  Map<String, StompClient> stompClients = {};
  final socketUrl = '$url/socket';

  ServerApi(
      this._dioApi,
      this._tokensStorage,
      this._containerForListConverter,
  );

  Future<Result<ContainerForList<T>>> _execRequestForList<T>({
    required FromJson<T> fromJson,
    required Future<Response> request
  }) async {
    try {
      Response response = await request;
      int? code = response.statusCode;
      if (code != null && code >= 200 && code < 300) {
        return SuccessResult(
            data: _containerForListConverter.fromJson<T>(
                json: response.data,
                fromJson: fromJson
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
    FromJson? fromJson,
    required Future<Response> request
  }) async {
    try {
      Response response = await request;
      int? code = response.statusCode;
      if (code != null && code >= 200 && code < 300) {
        return SuccessResult(data: fromJson?.call(response.data));
      } else {
        return getErrorFromResponse(response);
      }
    } on Exception catch(exception) {
      return getErrorFromException(exception);
    }
  }

  ErrorResult<T> getErrorFromResponse<T>(Response response) {
    if (response.statusCode == 500) {
      return ErrorResult(type: ErrorType.server);
    }
    final ErrorResult error = ErrorResult.fromJson(
        response.data
    );
    return ErrorResult(
        type: ErrorType.standard,
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
      return ErrorResult(type: ErrorType.timeout);
    }
    if (exception is SocketException && exception.osError?.errorCode == 101) {
      return ErrorResult(type: ErrorType.connection);
    }
    return ErrorResult(type: ErrorType.unknown);
  }

  Future<void> _saveTokens(SuccessResult<TokensModel> result) async {
    final tokens = result.data;
    await _tokensStorage.setAccessToken(accessToken: tokens.access);
    await _tokensStorage.setRefreshToken(refreshToken: tokens.refresh);
    await _tokensStorage.setUsername(username: tokens.username);
  }





  Future<Result> signup(SignupModel signup) => _execRequest(
      request: _dioApi.post(
        '$url$signupMethod',
        data: signup.toJson()
      )
  );

  Future<Result> confirm(ConfirmModel confirm) => _execRequest(
      request: _dioApi.post(
          '$url$confirmMethod',
          data: confirm.toJson()
      )
  );


  Future<Result<TokensModel>> login(LoginModel login) async {
    final result = await _execRequest<TokensModel>(
        fromJson: TokensModel.fromJson,
        request: _dioApi.post(
            '$url$loginMethod',
            data: login.toJson()
        )
    );
    if (result is SuccessResult) {
      await _saveTokens(result as SuccessResult<TokensModel>);
    }
    return result;
  }





  Future<Result<ContainerForList<LocationModel>>> getLocations(String username) => _execRequestForList(
      fromJson: LocationModel.fromJson,
      request: _dioApi.get(
        '$url/locations',
        queryParameters: {
          'username': username,
        }
      )
  );

  Future<Result<LocationModel>> createLocation(LocationModel location) => _execRequest(
      fromJson: LocationModel.fromJson,
      request: _dioApi.post(
          '$url/locations/create',
           data: location.toJson()
      )
  );

  Future<Result<LocationModel>> getLocation(int locationId, String? username) => _execRequest(
      fromJson: LocationModel.fromJson,
      request: _dioApi.get(
          '$url/locations/$locationId',
          queryParameters: { 'username': username }
      )
  );

  Future<Result> deleteLocation(int locationId) => _execRequest(
      request: _dioApi.delete(
          '$url/locations/$locationId/delete'
      )
  );

  Future<Result<HasRightsModel>> checkHasRights(String username) => _execRequest(
      fromJson: HasRightsModel.fromJson,
      request: _dioApi.get(
          '$url/locations/check',
          queryParameters: { 'username': username }
      )
  );




  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String username) => _execRequestForList(
      fromJson: QueueModel.fromJson,
      request: _dioApi.get(
          '$url/queues',
          queryParameters: {
            'username': username,
            'location_id': locationId,
          }
      )
  );

  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue) => _execRequest(
      fromJson: QueueModel.fromJson,
      request: _dioApi.post(
          '$url/queues/create',
          data: queue.toJson(),
          queryParameters: {
            'location_id': locationId
          }
      )
  );

  Future<Result> deleteQueue(int id) => _execRequest(
      request: _dioApi.delete(
        '$url/queues/$id/delete',
      )
  );


  Future<Result<QueueModel>> getQueueState(int id) => _execRequest(
      fromJson: QueueModel.fromJson,
      request: _dioApi.get(
          '$url/queues/$id'
      )
  );

  Future<Result> serveClientInQueue(int queueId, int clientId) => _execRequest(
      request: _dioApi.post(
          '$url/queues/$queueId/serve',
          queryParameters: { 'client_id': clientId }
      )
  );

  Future<Result> notifyClientInQueue(int queueId, int clientId) => _execRequest(
      request: _dioApi.post(
          '$url/queues/$queueId/notify',
          queryParameters: { 'client_id': clientId }
      )
  );

  Future<Result<ClientInQueueModel>> addClientToQueue(int queueId, AddClientInfo addClientInfo) => _execRequest(
      fromJson: ClientInQueueModel.fromJson,
      request: _dioApi.post(
          '$url/queues/$queueId/client/add',
          data: addClientInfo.toJson()
      )
  );





  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId, String? email, String? accessKey) =>_execRequest(
      fromJson: ClientModel.fromJson,
      request: _dioApi.get(
          '$url/queues/$queueId/client',
          queryParameters: {
            'email': email,
            'access_key': accessKey
          }
      )
  );

  Future<Result<ClientModel>> joinClientToQueue(int queueId, ClientJoinInfo clientJoinInfo) => _execRequest(
      fromJson: ClientModel.fromJson,
      request: _dioApi.post(
          '$url/queues/$queueId/client/join',
          data: clientJoinInfo.toJson(),
          queryParameters: {
            'queue_id': queueId
          }
      )
  );

  Future<Result<ClientModel>> rejoinClientToQueue(int queueId, String email) => _execRequest(
      fromJson: ClientModel.fromJson,
      request: _dioApi.post(
          '$url/queues/$queueId/client/rejoin',
          queryParameters: { 'email': email}
      )
  );

  Future<Result<ClientModel>> confirmClientCodeInQueue(int queueId, String email, String code) => _execRequest(
      fromJson: ClientModel.fromJson,
      request: _dioApi.post(
          '$url/queues/$queueId/client/confirm',
          queryParameters: {
            'email': email,
            'code': code
          }
      )
  );

  Future<Result<ClientModel>> leaveQueue(int queueId, String? email, String? accessKey) => _execRequest(
      fromJson: ClientModel.fromJson,
      request: _dioApi.post(
          '$url/queues/$queueId/client/leave',
          queryParameters: {
            'email': email,
            'access_key': accessKey
          }
      )
  );





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
          onQueueChanged.call(QueueModel.fromJson(json.decode(frame.body!)) as T);
        } else if (T == BoardModel) {
          onQueueChanged.call(BoardModel.fromJson(json.decode(frame.body!)) as T);
        }
      }
    );
  }





  Future<Result> addRights(int locationId, String email) => _execRequest(
      request: _dioApi.post(
          '$url/rights/add',
          queryParameters: {
            'location_id': locationId,
            'email': email
          }
      )
  );

  Future<Result> deleteRights(int locationId, String email) => _execRequest(
      request: _dioApi.delete(
          '$url/rights/delete',
          queryParameters: {
            'location_id': locationId,
            'email': email
          }
      )
  );


  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId) => _execRequestForList(
      fromJson: RightsModel.fromJson,
      request: _dioApi.get(
          '$url/rights',
          queryParameters: {
            'location_id': locationId
          }
      )
  );





  Future<Result<BoardModel>> getBoard(int locationId) => _execRequest(
      fromJson: BoardModel.fromJson,
      request: _dioApi.get(
          '$url/board',
          queryParameters: {
            'location_id': locationId,
          }
      )
  );
}
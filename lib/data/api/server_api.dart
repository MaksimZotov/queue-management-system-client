import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/location_change_event.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';
import 'package:queue_management_system_client/domain/models/location/change/location_add_client.dart';
import 'package:queue_management_system_client/domain/models/location/change/base/location_change_model.dart';
import 'package:queue_management_system_client/domain/models/location/create_location_request.dart';
import 'package:queue_management_system_client/domain/models/specialist/create_specialist_request.dart';
import 'package:queue_management_system_client/domain/models/service/create_service_request.dart';
import 'package:queue_management_system_client/domain/models/sequence/create_services_sequence_request.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/specialist/specialist_model.dart';
import 'package:queue_management_system_client/domain/models/sequence/services_sequence_model.dart';
import 'package:queue_management_system_client/domain/models/rights/add_rights_request.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';
import 'package:queue_management_system_client/domain/models/account/confirm_model.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/client/change_client_request.dart';
import '../../domain/models/client/client_model.dart';
import '../../domain/models/client/serve_client_request.dart';
import '../../domain/models/location/change/location_delete_client.dart';
import '../../domain/models/location/change/location_update_client.dart';
import '../../domain/models/location/state/location_state.dart';
import '../../domain/models/service/ordered_services_model.dart';
import '../../domain/models/service/service_model.dart';
import '../../domain/models/client/create_client_request.dart';
import '../../domain/models/queue/create_queue_request.dart';
import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/account/login_model.dart';
import '../../domain/models/account/signup_model.dart';
import '../../domain/models/account/tokens_model.dart';
import '../../domain/models/queue/queue_state_model.dart';
import '../converters/container_for_list_converter.dart';
import '../converters/from_json.dart';
import '../local/account_info_storage.dart';

@singleton
class ServerApi {

  static const url = String.fromEnvironment('SERVER_URL');
  static const clientUrl = String.fromEnvironment('CLIENT_URL');

  static const signupMethod = '/account/signup';
  static const confirmMethod = '/account/confirm';
  static const loginMethod = '/account/login';

  final Dio _dioApi;
  final AccountInfoStorage _accountInfoStorage;
  final ContainerForListConverter _containerForListConverter;

  Map<String, StompClient> stompClients = {};
  final socketUrl = '$url/socket';

  ServerApi(
      this._dioApi,
      this._accountInfoStorage,
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
    await _accountInfoStorage.setAccessToken(accessToken: tokens.access);
    await _accountInfoStorage.setRefreshToken(refreshToken: tokens.refresh);
    await _accountInfoStorage.setAccountId(accountId: tokens.accountId);
  }





  // <======================== Account ========================>
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
  // <======================== Account ========================>





  // <======================== Location ========================>
  Future<Result<ContainerForList<LocationModel>>> getLocations(int accountId) => _execRequestForList(
      fromJson: LocationModel.fromJson,
      request: _dioApi.get(
        '$url/locations',
        queryParameters: { 'account_id': accountId }
      )
  );

  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest) => _execRequest(
      fromJson: LocationModel.fromJson,
      request: _dioApi.post(
          '$url/locations/create',
           data: createLocationRequest.toJson()
      )
  );

  Future<Result> deleteLocation(int locationId) => _execRequest(
      request: _dioApi.delete(
          '$url/locations/$locationId/delete'
      )
  );

  Future<Result<LocationModel>> getLocation(int locationId) => _execRequest(
      fromJson: LocationModel.fromJson,
      request: _dioApi.get(
          '$url/locations/$locationId'
      )
  );

  Future<Result<LocationState>> getLocationState(int locationId) => _execRequest(
      fromJson: LocationState.fromJson,
      request: _dioApi.get(
          '$url/locations/$locationId/state'
      )
  );
  // <======================== Location ========================>





  // <======================== Service ========================>
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId) => _execRequestForList(
      fromJson: ServiceModel.fromJson,
      request: _dioApi.get(
          '$url/services',
          queryParameters: { 'location_id': locationId }
      )
  );

  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId) => _execRequestForList(
      fromJson: ServiceModel.fromJson,
      request: _dioApi.get(
          '$url/services',
          queryParameters: { 'queue_id': queueId }
      )
  );

  Future<Result<ContainerForList<ServiceModel>>> getServicesInSpecialist(int specialistId) => _execRequestForList(
      fromJson: ServiceModel.fromJson,
      request: _dioApi.get(
          '$url/services',
          queryParameters: { 'specialist_id': specialistId }
      )
  );

  Future<Result<OrderedServicesModel>> getServicesInServicesSequence(int servicesSequenceId) => _execRequest(
      fromJson: OrderedServicesModel.fromJson,
      request: _dioApi.get(
          '$url/services',
          queryParameters: { 'services_sequence_id': servicesSequenceId }
      )
  );

  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest) => _execRequest(
      fromJson: ServiceModel.fromJson,
      request: _dioApi.post(
          '$url/services/create',
          queryParameters: { 'location_id': locationId },
          data: createServiceRequest.toJson()
      )
  );

  Future<Result> deleteServiceInLocation(int locationId, int serviceId) => _execRequest(
      request: _dioApi.delete(
          '$url/services/$serviceId/delete',
          queryParameters: { 'location_id': locationId }
      )
  );
  // <======================== Service ========================>





  // <======================== ServicesSequence ========================>
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId) => _execRequestForList(
      fromJson: ServicesSequenceModel.fromJson,
      request: _dioApi.get(
          '$url/services_sequences',
          queryParameters: { 'location_id': locationId }
      )
  );

  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest) => _execRequest(
      fromJson: ServicesSequenceModel.fromJson,
      request: _dioApi.post(
          '$url/services_sequences/create',
          queryParameters: { 'location_id': locationId },
          data: createServicesSequenceRequest.toJson()
      )
  );

  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequenceId) => _execRequest(
      request: _dioApi.delete(
          '$url/services_sequences/$servicesSequenceId/delete',
          queryParameters: { 'location_id': locationId }
      )
  );
  // <======================== ServicesSequence ========================>





  // <======================== Specialist ========================>
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId) => _execRequestForList(
      fromJson: SpecialistModel.fromJson,
      request: _dioApi.get(
          '$url/specialists',
          queryParameters: { 'location_id': locationId }
      )
  );

  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest) => _execRequest(
      fromJson: SpecialistModel.fromJson,
      request: _dioApi.post(
          '$url/specialists/create',
          queryParameters: { 'location_id': locationId },
          data: createSpecialistRequest.toJson()
      )
  );

  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId) => _execRequest(
      request: _dioApi.delete(
          '$url/specialists/$specialistId/delete',
          queryParameters: { 'location_id': locationId }
      )
  );
  // <======================== Specialist ========================>





  // <======================== Queue ========================>
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId) => _execRequestForList(
      fromJson: QueueModel.fromJson,
      request: _dioApi.get(
          '$url/queues',
          queryParameters: { 'location_id': locationId }
      )
  );

  Future<Result<QueueModel>> createQueue(int locationId, CreateQueueRequest createQueueRequest) => _execRequest(
      fromJson: QueueModel.fromJson,
      request: _dioApi.post(
          '$url/queues/create',
          queryParameters: { 'location_id': locationId },
          data: createQueueRequest.toJson()
      )
  );

  Future<Result> deleteQueue(int queueId) => _execRequest(
      request: _dioApi.delete(
        '$url/queues/$queueId/delete'
      )
  );


  Future<Result<QueueStateModel>> getQueueState(int queueId) => _execRequest(
      fromJson: QueueStateModel.fromJson,
      request: _dioApi.get(
          '$url/queues/$queueId/state'
      )
  );
  // <======================== Queue ========================>





  // <======================== Client ========================>
  Future<Result<ClientModel>> createClientInLocation(int locationId, CreateClientRequest createClientRequest) => _execRequest(
      fromJson: ClientModel.fromJson,
      request: _dioApi.post(
          '$url/clients/create',
          queryParameters: { 'location_id': locationId },
          data: createClientRequest.toJson()
      )
  );

  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey) => _execRequest(
      fromJson: QueueStateForClientModel.fromJson,
      request: _dioApi.post(
        '$url/clients/$clientId/confirm',
        queryParameters: { 'access_key': accessKey },
      )
  );

  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId) => _execRequest(
      fromJson: QueueStateForClientModel.fromJson,
      request: _dioApi.get(
        '$url/clients/$clientId/state'
      )
  );

  Future<Result> deleteClientInLocation(int locationId, int clientId) => _execRequest(
      request: _dioApi.delete(
        '$url/clients/$clientId/delete',
        queryParameters: { 'location_id': locationId },
      )
  );

  Future<Result> changeClientInLocation(int locationId, int clientId, ChangeClientRequest changeClientRequest) => _execRequest(
      request: _dioApi.post(
          '$url/clients/$clientId/change',
          queryParameters: { 'location_id': locationId },
          data: changeClientRequest.toJson()
      )
  );

  Future<Result> serveClientInQueue(int queueId, int clientId, ServeClientRequest serveClientRequest) => _execRequest(
      request: _dioApi.post(
          '$url/clients/$clientId/serve',
          queryParameters: { 'queue_id': queueId },
          data: serveClientRequest.toJson()
      )
  );

  Future<Result> callClientInQueue(int queueId, int clientId) => _execRequest(
      request: _dioApi.post(
          '$url/clients/$clientId/call',
          queryParameters: { 'queue_id': queueId }
      )
  );

  Future<Result> returnClientToQueue(int queueId, int clientId) => _execRequest(
      request: _dioApi.post(
          '$url/clients/$clientId/return',
          queryParameters: { 'queue_id': queueId }
      )
  );

  Future<Result> notifyClientInQueue(int queueId, int clientId) => _execRequest(
      request: _dioApi.post(
          '$url/clients/$clientId/notify',
          queryParameters: { 'queue_id': queueId }
      )
  );
  // <======================== Client ========================>





  // <======================== Rights ========================>
  Future<Result> addRights(int locationId, AddRightsRequest addRightsRequest) => _execRequest(
      request: _dioApi.post(
          '$url/rights/add',
          queryParameters: {'location_id': locationId},
          data: addRightsRequest.toJson()
      )
  );

  Future<Result> deleteRights(int locationId, String email) => _execRequest(
      request: _dioApi.delete(
          '$url/rights/$email/delete',
          queryParameters: {
            'location_id': locationId
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
  // <======================== Rights ========================>





  // <======================== Socket ========================>
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
          if (T == LocationChange) {
            Map<String, dynamic> jsonMap = json.decode(frame.body!);
            String event = jsonMap[LocationChange.eventFieldName] as String;
            _handleLocationChangeEvent(
                event,
                jsonMap,
                onQueueChanged as ValueChanged<LocationChange>
            );
          }
        }
    );
  }

  void _handleLocationChangeEvent(
      String event,
      Map<String, dynamic> jsonMap,
      ValueChanged<LocationChange> onQueueChanged,
  ) {
    if (event == LocationChangeEvent.addClient.serverName) {
      onQueueChanged(LocationAddClient.fromJson(jsonMap));
    } else if (event == LocationChangeEvent.updateClient.serverName) {
      onQueueChanged(LocationUpdateClient.fromJson(jsonMap));
    } else if (event == LocationChangeEvent.deleteClient.serverName) {
      onQueueChanged(LocationDeleteClient.fromJson(jsonMap));
    }
  }
  // <======================== Socket ========================>
}
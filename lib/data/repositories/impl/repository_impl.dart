import 'dart:ui';

import 'package:flutter/src/foundation/basic_types.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/data/repositories/repository.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/client/add_client_request.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';
import 'package:queue_management_system_client/domain/models/location/board_model.dart';
import 'package:queue_management_system_client/domain/models/location/create_queue_type_request.dart';
import 'package:queue_management_system_client/domain/models/location/create_service_request.dart';
import 'package:queue_management_system_client/domain/models/location/create_services_sequence_request.dart';
import 'package:queue_management_system_client/domain/models/location/has_rights_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/location/queue_type_model.dart';
import 'package:queue_management_system_client/domain/models/location/services_sequence_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';

import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/create_location_request.dart';
import '../../../domain/models/location/service_model.dart';
import '../../../domain/models/account/confirm_model.dart';
import '../../../domain/models/account/login_model.dart';
import '../../../domain/models/account/signup_model.dart';
import '../../../domain/models/account/tokens_model.dart';
import '../../../domain/models/queue/create_queue_request.dart';
import '../../../domain/models/queue/queue_state_model.dart';
import '../../local/secure_storage.dart';
import '../../local/shared_preferences_storage.dart';

@Singleton(as: Repository)
class RepositoryImpl extends Repository {

  final ServerApi _serverApi;
  final SharedPreferencesStorage _sharedPreferencesStorage;
  final SecureStorage _secureStorage;

  RepositoryImpl(
      this._serverApi,
      this._sharedPreferencesStorage,
      this._secureStorage
  );





  // <======================== Account ========================>
  @override
  Future<Result<TokensModel>> login(LoginModel login) {
    return _serverApi.login(login);
  }

  @override
  Future<Result> confirm(ConfirmModel confirm) {
    return _serverApi.confirm(confirm);
  }

  @override
  Future<Result> signup(SignupModel signup) {
    return _serverApi.signup(signup);
  }

  @override
  Future<bool> checkToken() {
    return _secureStorage.containsAccessToken();
  }

  @override
  Future<void> logout() {
    return _secureStorage.deleteAll();
  }

  @override
  Future<String?> getCurrentUsername() async {
    if (!(await _secureStorage.containsUsername())) {
      return null;
    }
    return (await _secureStorage.getUsername());
  }
  // <======================== Account ========================>





  // <======================== Location ========================>
  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(String? username) async {
    if (username == null && await _secureStorage.containsUsername()) {
      return await _serverApi.getLocations((await _secureStorage.getUsername())!);
    }
    if (username != null) {
      return await _serverApi.getLocations(username);
    }
    return ErrorResult(type: ErrorType.unknown);
  }

  @override
  Future<Result<HasRightsModel>> checkHasRights(String? username) async {
    if (username == null && !(await _secureStorage.containsUsername())) {
      return SuccessResult(data: HasRightsModel(hasRights: false));
    }
    return await _serverApi.checkHasRights(username ?? (await _secureStorage.getUsername())!);
  }

  @override
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest) {
    return _serverApi.createLocation(createLocationRequest);
  }

  @override
  Future<Result> deleteLocation(int locationId) {
    return _serverApi.deleteLocation(locationId);
  }

  @override
  Future<Result<LocationModel>> getLocation(int locationId, String? username) {
    return _serverApi.getLocation(locationId, username);
  }

  @override
  Future<Result<LocationModel>> changeMaxColumns(int locationId, int maxColumns) {
    return _serverApi.changeMaxColumns(locationId, maxColumns);
  }

  @override
  Future<Result<BoardModel>> getLocationBoard(int locationId) {
    return _serverApi.getLocationBoard(locationId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId) {
    return _serverApi.getServicesInLocation(locationId);
  }

  @override
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest) {
    return _serverApi.createServiceInLocation(locationId, createServiceRequest);
  }

  @override
  Future<Result> deleteServiceInLocation(int locationId, int serviceId) {
    return _serverApi.deleteServiceInLocation(locationId, serviceId);
  }

  @override
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId) {
    return _serverApi.getServicesSequencesInLocation(locationId);
  }

  @override
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest) {
    return _serverApi.createServicesSequenceInLocation(locationId, createServicesSequenceRequest);
  }

  @override
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence) {
    return _serverApi.deleteServicesSequenceInLocation(locationId, servicesSequence);
  }

  @override
  Future<Result<ContainerForList<QueueTypeModel>>> getQueueTypesInLocation(int locationId) {
    return _serverApi.getQueueTypesInLocation(locationId);
  }

  @override
  Future<Result<QueueTypeModel>> createQueueTypeInLocation(int locationId, CreateQueueTypeRequest createQueueTypeRequest) {
    return _serverApi.createQueueTypeInLocation(locationId, createQueueTypeRequest);
  }

  @override
  Future<Result> deleteQueueTypeInLocation(int locationId, int queueTypeId) {
    return _serverApi.deleteQueueTypeInLocation(locationId, queueTypeId);
  }

  @override
  Future<Result> pauseLocation(int locationId) {
    return _serverApi.pauseLocation(locationId);
  }

  @override
  Future<Result> startLocation(int locationId) {
    return _serverApi.startLocation(locationId);
  }

  @override
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest) {
    return _serverApi.addClientInLocation(locationId, addClientRequest);
  }
  // <======================== Location ========================>





  // <======================== Queue ========================>
  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String username) {
    return _serverApi.getQueues(locationId, username);
  }

  @override
  Future<Result<QueueModel>> createQueue(int locationId, CreateQueueRequest createQueueRequest) {
    return _serverApi.createQueue(locationId, createQueueRequest);
  }

  @override
  Future<Result> deleteQueue(int queueId) {
    return _serverApi.deleteQueue(queueId);
  }

  @override
  Future<Result<QueueStateModel>> getQueueState(int queueId) {
    return _serverApi.getQueueState(queueId);
  }

  @override
  Future<Result> pauseQueue(int queueId) {
    return _serverApi.pauseQueue(queueId);
  }

  @override
  Future<Result> startQueue(int queueId) {
    return _serverApi.startQueue(queueId);
  }

  @override
  Future<Result> notifyClientInQueue(int queueId, int clientId) {
    return _serverApi.notifyClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> serveClientInQueue(int queueId, int clientId) {
    return _serverApi.serveClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> switchClientLateStateInQueue(int queueId, int clientId, bool late) {
    return _serverApi.switchClientLateStateInQueue(queueId, clientId, late);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId) {
    return _serverApi.getServicesInQueue(queueId);
  }
  // <======================== Queue ========================>





  // <======================== Client ========================>
  @override
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId, String accessKey) {
    return _serverApi.getQueueStateForClient(clientId, accessKey);
  }

  @override
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey) {
    return _serverApi.confirmAccessKeyByClient(clientId, accessKey);
  }

  @override
  Future<Result<QueueStateForClientModel>> leaveQueue(int clientId, String accessKey) async {
    return _serverApi.leaveQueue(clientId, accessKey);
  }
  // <======================== Client ========================>





  // <======================== Rights ========================>
  @override
  Future<Result> addRights(int locationId, String email) {
    return _serverApi.addRights(locationId, email);
  }

  @override
  Future<Result> deleteRights(int locationId, String email) {
    return _serverApi.deleteRights(locationId, email);
  }

  @override
  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId) {
    return _serverApi.getRights(locationId);
  }
  // <======================== Rights ========================>





  // <======================== Socket ========================>
  @override
  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError) {
    _serverApi.connectToSocket(destination, onConnected, onQueueChanged, onError);
  }

  @override
  void disconnectFromSocket(String destination) {
    _serverApi.disconnectFromSocket(destination);
  }
// <======================== Socket ========================>
}
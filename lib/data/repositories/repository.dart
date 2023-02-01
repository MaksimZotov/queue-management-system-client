import 'package:flutter/cupertino.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/account/confirm_model.dart';
import 'package:queue_management_system_client/domain/models/location/create_queue_type_request.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/client/queue_state_for_client_model.dart';
import '../../domain/models/location/board_model.dart';
import '../../domain/models/location/create_location_request.dart';
import '../../domain/models/location/create_service_request.dart';
import '../../domain/models/location/create_services_sequence_request.dart';
import '../../domain/models/location/has_rights_model.dart';
import '../../domain/models/location/location_model.dart';
import '../../domain/models/client/add_client_request.dart';
import '../../domain/models/location/queue_type_model.dart';
import '../../domain/models/location/service_model.dart';
import '../../domain/models/location/services_sequence_model.dart';
import '../../domain/models/queue/create_queue_request.dart';
import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/queue/queue_state_model.dart';
import '../../domain/models/rights/rights_model.dart';
import '../../domain/models/account/login_model.dart';
import '../../domain/models/account/signup_model.dart';
import '../../domain/models/account/tokens_model.dart';
import '../../domain/models/terminal/terminal_state.dart';

abstract class Repository {
  // <======================== Account ========================>
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result<TokensModel>> login(LoginModel login);
  Future<bool> checkToken();
  Future<void> logout();
  Future<String?> getCurrentUsername();
  // <======================== Account ========================>

  // <======================== Location ========================>
  Future<Result<ContainerForList<LocationModel>>> getLocations(String? username);
  Future<Result<HasRightsModel>> checkHasRights(String? username);
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest);
  Future<Result> deleteLocation(int locationId);
  Future<Result<LocationModel>> getLocation(int locationId, String? username);
  Future<Result<LocationModel>> changeMaxColumns(int locationId, int maxColumns);
  Future<Result<BoardModel>> getLocationBoard(int locationId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId);
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest);
  Future<Result> deleteServiceInLocation(int locationId, int serviceId);
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId);
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest);
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence);
  Future<Result<ContainerForList<QueueTypeModel>>> getQueueTypesInLocation(int locationId);
  Future<Result<QueueTypeModel>> createQueueTypeInLocation(int locationId, CreateQueueTypeRequest createQueueTypeRequest);
  Future<Result> deleteQueueTypeInLocation(int locationId, int queueTypeId);
  Future<Result> pauseLocation(int locationId);
  Future<Result> startLocation(int locationId);
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest);
  // <======================== Location ========================>

  // <======================== Queue ========================>
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String username);
  Future<Result<QueueModel>> createQueue(int locationId, CreateQueueRequest createQueueRequest);
  Future<Result> deleteQueue(int queueId);
  Future<Result<QueueStateModel>> getQueueState(int queueId);
  Future<Result> pauseQueue(int queueId);
  Future<Result> startQueue(int queueId);
  Future<Result> serveClientInQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
  Future<Result> switchClientLateStateInQueue(int queueId, int clientId, bool late);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId);
  // <======================== Queue ========================>

  // <======================== Client ========================>
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> leaveQueue(int clientId, String accessKey);
  // <======================== Client ========================>

  // <======================== Rights ========================>
  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId);
  Future<Result> addRights(int locationId, String email);
  Future<Result> deleteRights(int locationId, String email);
  // <======================== Rights ========================>

  // <======================== Terminal ========================>
  Future<void> setTerminalState(TerminalState terminalState);
  Future<TerminalState?> getTerminalState();
  Future<void> clearTerminalState();
  // <======================== Terminal ========================>

  // <======================== Socket ========================>
  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError);
  void disconnectFromSocket(String destination);
  // <======================== Socket ========================>
}
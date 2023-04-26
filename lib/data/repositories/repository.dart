import 'package:flutter/cupertino.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/account/confirm_model.dart';
import 'package:queue_management_system_client/domain/models/client/change_client_request.dart';
import 'package:queue_management_system_client/domain/models/specialist/create_specialist_request.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/client/client_model.dart';
import '../../domain/models/client/queue_state_for_client_model.dart';
import '../../domain/models/client/serve_client_request.dart';
import '../../domain/models/location/create_location_request.dart';
import '../../domain/models/service/create_service_request.dart';
import '../../domain/models/sequence/create_services_sequence_request.dart';
import '../../domain/models/location/check_is_owner_model.dart';
import '../../domain/models/location/location_model.dart';
import '../../domain/models/client/create_client_request.dart';
import '../../domain/models/service/ordered_services_model.dart';
import '../../domain/models/specialist/specialist_model.dart';
import '../../domain/models/service/service_model.dart';
import '../../domain/models/sequence/services_sequence_model.dart';
import '../../domain/models/location/location_state.dart';
import '../../domain/models/queue/create_queue_request.dart';
import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/queue/queue_state_model.dart';
import '../../domain/models/rights/add_rights_request.dart';
import '../../domain/models/rights/rights_model.dart';
import '../../domain/models/account/login_model.dart';
import '../../domain/models/account/signup_model.dart';
import '../../domain/models/account/tokens_model.dart';

abstract class Repository {
  // <======================== Account ========================>
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result<TokensModel>> login(LoginModel login);
  Future<bool> checkToken();
  Future<void> logout();
  Future<int?> getCurrentAccountId();
  // <======================== Account ========================>

  // <======================== Location ========================>
  Future<Result<ContainerForList<LocationModel>>> getLocations(int? accountId);
  Future<Result<CheckIsOwnerModel>> checkIsOwner(int? accountId);
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest);
  Future<Result> deleteLocation(int locationId);
  Future<Result<LocationModel>> getLocation(int locationId);
  Future<Result<LocationState>> getLocationState(int locationId);
  // <======================== Location ========================>

  // <======================== Service ========================>
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInSpecialist(int specialistId);
  Future<Result<OrderedServicesModel>> getServicesInServicesSequence(int servicesSequenceId);
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest);
  Future<Result> deleteServiceInLocation(int locationId, int serviceId);
  // <======================== Service ========================>

  // <======================== ServicesSequence ========================>
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId);
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest);
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence);
  // <======================== ServicesSequence ========================>

  // <======================== Specialist ========================>
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId);
  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest);
  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId);
  // <======================== Specialist ========================>

  // <======================== Queue ========================>
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId);
  Future<Result<QueueModel>> createQueue(int locationId, CreateQueueRequest createQueueRequest);
  Future<Result> deleteQueue(int queueId);
  Future<Result<QueueStateModel>> getQueueState(int queueId);
  // <======================== Queue ========================>

  // <======================== Client ========================>
  Future<Result<ClientModel>> createClientInLocation(int locationId, CreateClientRequest addClientRequest, String ticketNumberText);
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId);
  Future<Result> deleteClientInLocation(int locationId, int clientId);
  Future<Result> changeClientInLocation(int locationId, int clientId, ChangeClientRequest changeClientRequest);
  Future<Result> serveClientInQueue(int queueId, int clientId, ServeClientRequest serveClientRequest);
  Future<Result> callClientInQueue(int queueId, int clientId);
  Future<Result> returnClientToQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
  // <======================== Client ========================>

  // <======================== Rights ========================>
  Future<Result> addRights(int locationId, AddRightsRequest addRightsRequest);
  Future<Result> deleteRights(int locationId, String email);
  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId);
  // <======================== Rights ========================>

  // <======================== Kiosk ========================>
  Future<bool> enableKioskMode(bool printerEnabled);
  Future<bool> getPrinterEnabled();
  // <======================== Kiosk ========================>

  // <======================== Socket ========================>
  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError);
  void disconnectFromSocket(String destination);
  // <======================== Socket ========================>
}
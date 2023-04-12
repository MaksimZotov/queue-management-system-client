import 'package:flutter/cupertino.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/account/confirm_model.dart';
import 'package:queue_management_system_client/domain/models/client/change_client_request.dart';
import 'package:queue_management_system_client/domain/models/location/create_specialist_request.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/client/queue_state_for_client_model.dart';
import '../../domain/models/client/serve_client_request.dart';
import '../../domain/models/kiosk/printer_data.dart';
import '../../domain/models/location/create_location_request.dart';
import '../../domain/models/location/create_service_request.dart';
import '../../domain/models/location/create_services_sequence_request.dart';
import '../../domain/models/location/check_is_owner_model.dart';
import '../../domain/models/location/location_model.dart';
import '../../domain/models/client/add_client_request.dart';
import '../../domain/models/location/specialist_model.dart';
import '../../domain/models/location/service_model.dart';
import '../../domain/models/location/services_sequence_model.dart';
import '../../domain/models/locationnew/location_state.dart';
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
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId);
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest);
  Future<Result> deleteServiceInLocation(int locationId, int serviceId);
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId);
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest);
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence);
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId);
  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest);
  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId);
  Future<Result> disableLocation(int locationId);
  Future<Result> enableLocation(int locationId);
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest);
  Future<Result> changeClientInLocation(int locationId, ChangeClientRequest changeClientRequest);
  // <======================== Location ========================>

  // <======================== Queue ========================>
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId);
  Future<Result<QueueModel>> createQueue(int locationId, CreateQueueRequest createQueueRequest);
  Future<Result> deleteQueue(int queueId);
  Future<Result<QueueStateModel>> getQueueState(int queueId);
  Future<Result> disableQueue(int queueId);
  Future<Result> enableQueue(int queueId);
  Future<Result> serveClientInQueue(ServeClientRequest serveClientRequest);
  Future<Result> callClientInQueue(int queueId, int clientId);
  Future<Result> returnClientToQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInSpecialist(int specialistId);
  // <======================== Queue ========================>

  // <======================== Client ========================>
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> leaveQueue(int clientId, String accessKey);
  Future<Result> deleteClientInLocation(int locationId, int clientId);
  // <======================== Client ========================>

  // <======================== Rights ========================>
  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId);
  Future<Result> addRights(int locationId, AddRightsRequest addRightsRequest);
  Future<Result> deleteRights(int locationId, String email);
  // <======================== Rights ========================>

  // <======================== Kiosk ========================>
  Future<void> enableKioskMode(PrinterData printerDate);
  Future<PrinterData> getPrinterData();
  // <======================== Kiosk ========================>

  // <======================== Socket ========================>
  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError);
  void disconnectFromSocket(String destination);
  // <======================== Socket ========================>
}
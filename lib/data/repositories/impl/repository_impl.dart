import 'dart:ui';

import 'package:flutter/src/foundation/basic_types.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/data/repositories/repository.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/client/add_client_request.dart';
import 'package:queue_management_system_client/domain/models/client/change_client_request.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';
import 'package:queue_management_system_client/domain/models/location/create_specialist_request.dart';
import 'package:queue_management_system_client/domain/models/location/create_service_request.dart';
import 'package:queue_management_system_client/domain/models/location/create_services_sequence_request.dart';
import 'package:queue_management_system_client/domain/models/location/check_is_owner_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/location/specialist_model.dart';
import 'package:queue_management_system_client/domain/models/location/services_sequence_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';

import '../../../domain/models/base/result.dart';
import '../../../domain/models/client/serve_client_request.dart';
import '../../../domain/models/kiosk/printer_data.dart';
import '../../../domain/models/location/create_location_request.dart';
import '../../../domain/models/location/service_model.dart';
import '../../../domain/models/account/confirm_model.dart';
import '../../../domain/models/account/login_model.dart';
import '../../../domain/models/account/signup_model.dart';
import '../../../domain/models/account/tokens_model.dart';
import '../../../domain/models/locationnew/location_state.dart';
import '../../../domain/models/queue/create_queue_request.dart';
import '../../../domain/models/queue/queue_state_model.dart';
import '../../../domain/models/rights/add_rights_request.dart';
import '../../local/secure_storage.dart';
import '../../local/shared_preferences_storage.dart';
import '../../native/android/android_native_interactor.dart';
import '../../printer/printer_interactor.dart';

@Singleton(as: Repository)
class RepositoryImpl extends Repository {

  final ServerApi _serverApi;
  final SharedPreferencesStorage _sharedPreferencesStorage;
  final SecureStorage _secureStorage;
  final AndroidNativeInteractor _androidNativeInteractor;
  final PrinterInteractor _printerInteractor;

  RepositoryImpl(
      this._serverApi,
      this._sharedPreferencesStorage,
      this._secureStorage,
      this._androidNativeInteractor,
      this._printerInteractor
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
  Future<int?> getCurrentAccountId() async {
    if (!(await _secureStorage.containsAccountId())) {
      return null;
    }
    return (await _secureStorage.getAccountId());
  }
  // <======================== Account ========================>





  // <======================== Location ========================>
  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(int? accountId) async {
    if (accountId == null && await _secureStorage.containsAccountId()) {
      return await _serverApi.getLocations((await _secureStorage.getAccountId())!);
    }
    if (accountId != null) {
      return await _serverApi.getLocations(accountId);
    }
    return ErrorResult(type: ErrorType.unknown);
  }

  @override
  Future<Result<CheckIsOwnerModel>> checkIsOwner(int? accountId) async {
    if (accountId == null && !(await _secureStorage.containsAccountId())) {
      return SuccessResult(data: CheckIsOwnerModel(isOwner: false));
    }
    return await _serverApi.checkIsOwner(accountId ?? (await _secureStorage.getAccountId())!);
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
  Future<Result<LocationModel>> getLocation(int locationId) {
    return _serverApi.getLocation(locationId);
  }

  @override
  Future<Result<LocationState>> getLocationState(int locationId) {
    return _serverApi.getLocationState(locationId);
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
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId) {
    return _serverApi.getSpecialistsInLocation(locationId);
  }

  @override
  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest) {
    return _serverApi.createSpecialistInLocation(locationId, createSpecialistRequest);
  }

  @override
  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId) {
    return _serverApi.deleteSpecialistInLocation(locationId, specialistId);
  }

  @override
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest) async {
    Result result = await _serverApi.addClientInLocation(locationId, addClientRequest);
    result.onSuccess((result) async {
      PrinterData printerData = await _sharedPreferencesStorage.getPrinterData();
      _printerInteractor.print(
        printerData.ip,
        printerData.port
      );
    });
    return result;
  }

  @override
  Future<Result> changeClientInLocation(int locationId, ChangeClientRequest changeClientRequest) {
    return _serverApi.changeClientInLocation(locationId, changeClientRequest);
  }
  // <======================== Location ========================>





  // <======================== Queue ========================>
  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId) {
    return _serverApi.getQueues(locationId);
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
  Future<Result> notifyClientInQueue(int queueId, int clientId) {
    return _serverApi.notifyClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> serveClientInQueue(ServeClientRequest serveClientRequest) {
    return _serverApi.serveClientInQueue(serveClientRequest);
  }

  @override
  Future<Result> callClientInQueue(int queueId, int clientId) {
    return _serverApi.callClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> returnClientToQueue(int queueId, int clientId) {
    return _serverApi.returnClientToQueue(queueId, clientId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId) {
    return _serverApi.getServicesInQueue(queueId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInSpecialist(int specialistId) {
    return _serverApi.getServicesInSpecialist(specialistId);
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

  @override
  Future<Result> deleteClientInLocation(int locationId, int clientId) {
    return _serverApi.deleteClientInLocation(locationId, clientId);
  }
  // <======================== Client ========================>





  // <======================== Rights ========================>
  @override
  Future<Result> addRights(int locationId, AddRightsRequest addRightsRequest) {
    return _serverApi.addRights(locationId, addRightsRequest);
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




  // <======================== Kiosk ========================>
  @override
  Future<PrinterData> getPrinterData() {
    return _sharedPreferencesStorage.getPrinterData();
  }

  @override
  Future<void> enableKioskMode(PrinterData printerDate) async {
    await _androidNativeInteractor.enableLockTask();
    return _sharedPreferencesStorage.setPrinterData(printerDate);
  }
  // <======================== Kiosk ========================>




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
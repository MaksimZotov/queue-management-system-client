import 'dart:ui';

import 'package:flutter/src/foundation/basic_types.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/data/repositories/repository.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/board/board_model.dart';
import 'package:queue_management_system_client/domain/models/client/client_model.dart';
import 'package:queue_management_system_client/domain/models/location/has_rights_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';

import '../../../domain/models/base/result.dart';
import '../../../domain/models/client/client_join_info_model.dart';
import '../../../domain/models/queue/add_client_info.dart';
import '../../../domain/models/queue/client_in_queue_model.dart';
import '../../../domain/models/account/confirm_model.dart';
import '../../../domain/models/account/login_model.dart';
import '../../../domain/models/account/signup_model.dart';
import '../../../domain/models/account/tokens_model.dart';
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





  @override
  Future<Result<TokensModel>> login(LoginModel login) async {
    return await _serverApi.login(login);
  }

  @override
  Future<Result> confirm(ConfirmModel confirm) async {
    return await _serverApi.confirm(confirm);
  }

  @override
  Future<Result> signup(SignupModel signup) async {
    return await _serverApi.signup(signup);
  }

  @override
  Future<bool> checkToken() async {
    return await _secureStorage.containsAccessToken();
  }

  @override
  Future logout() async {
    await _secureStorage.deleteAll();
  }

  @override
  Future<String?> getCurrentUsername() async {
    if (!(await _secureStorage.containsUsername())) {
      return null;
    }
    return (await _secureStorage.getUsername());
  }




  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(String? username) async {
    if (username == null && await _secureStorage.containsUsername()) {
      return await _serverApi.getLocations((await _secureStorage.getUsername())!);
    }
    if (username != null) {
      return await _serverApi.getLocations(username);
    }
    return ErrorResult();
  }

  @override
  Future<Result<LocationModel>> createLocation(LocationModel location) async {
    return await _serverApi.createLocation(location);
  }

  @override
  Future<Result<LocationModel>> getLocation(int id, String? username) async {
    return await _serverApi.getLocation(id, username);
  }

  @override
  Future<Result> deleteLocation(int locationId) async {
    return await _serverApi.deleteLocation(locationId);
  }

  @override
  Future<Result<HasRightsModel>> checkHasRights(String? username) async {
    if (username == null && !(await _secureStorage.containsUsername())) {
      return SuccessResult(data: HasRightsModel(hasRights: false));
    }
    return await _serverApi.checkHasRights(username ?? (await _secureStorage.getUsername())!);
  }





  @override
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue) async {
    return await _serverApi.createQueue(locationId, queue);
  }

  @override
  Future<Result> deleteQueue(int id) async {
    return await _serverApi.deleteQueue(id);
  }

  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String username) async {
    return await _serverApi.getQueues(locationId, username);
  }

  @override
  Future<Result<QueueModel>> getQueueState(int id) async {
    return await _serverApi.getQueueState(id);
  }

  @override
  Future<Result> notifyClientInQueue(int queueId, int clientId) async {
    return await _serverApi.notifyClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> serveClientInQueue(int queueId, int clientId) async {
    return await _serverApi.serveClientInQueue(queueId, clientId);
  }

  @override
  Future<Result<ClientInQueueModel>> addClientToQueue(int queueId, AddClientInfo addClientInfo) async {
    return await _serverApi.addClientToQueue(queueId, addClientInfo);
  }

  @override
  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError) {
    _serverApi.connectToSocket(destination, onConnected, onQueueChanged, onError);
  }

  @override
  void disconnectFromSocket(String destination) {
    _serverApi.disconnectFromSocket(destination);
  }





  @override
  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId) async {
    String? email = await _sharedPreferencesStorage.getClientInQueueEmail();
    String? accessKey = await _sharedPreferencesStorage.getClientInQueueAccessKey();
    return await _serverApi.getClientInQueue(username, locationId, queueId, email, accessKey)
      ..onSuccess((result) async {
        await _sharedPreferencesStorage.setClientInQueueEmail(email: result.data.email);
        await _sharedPreferencesStorage.setClientInQueueAccessKey(accessKey: result.data.accessKey);
      });
  }

  @override
  Future<Result<ClientModel>> joinClientToQueue(String username, int locationId, int queueId, ClientJoinInfo clientJoinInfo) async {
    return await _serverApi.joinClientToQueue(username, locationId, queueId, clientJoinInfo)
      ..onSuccess((result) async {
        await _sharedPreferencesStorage.setClientInQueueEmail(email: result.data.email);
        await _sharedPreferencesStorage.setClientInQueueAccessKey(accessKey: result.data.accessKey);
      });
  }

  @override
  Future<Result<ClientModel>> confirmClientCodeInQueue(int queueId, String email, String code) async {
    return await _serverApi.confirmClientCodeInQueue(queueId, email, code)
      ..onSuccess((result) async {
        await _sharedPreferencesStorage.setClientInQueueEmail(email: result.data.email);
        await _sharedPreferencesStorage.setClientInQueueAccessKey(accessKey: result.data.accessKey);
      });
  }

  @override
  Future<Result<ClientModel>> leaveQueue(int queueId) async {
    String? email = await _sharedPreferencesStorage.getClientInQueueEmail();
    String? accessKey = await _sharedPreferencesStorage.getClientInQueueAccessKey();
    return await _serverApi.leaveQueue(queueId, email, accessKey)
      ..onSuccess((result) async {
        await _sharedPreferencesStorage.setClientInQueueEmail(email: result.data.email);
        await _sharedPreferencesStorage.setClientInQueueAccessKey(accessKey: result.data.accessKey);
      });
  }

  @override
  Future<Result<ClientModel>> rejoinClientToQueue(int queueId, String email) async {
    return await _serverApi.rejoinClientToQueue(queueId, email)
      ..onSuccess((result) async {
        await _sharedPreferencesStorage.setClientInQueueEmail(email: result.data.email);
        await _sharedPreferencesStorage.setClientInQueueAccessKey(accessKey: result.data.accessKey);
      });
  }





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





  @override
  Future<Result<BoardModel>> getBoard(int locationId) {
    return _serverApi.getBoard(locationId);
  }

}
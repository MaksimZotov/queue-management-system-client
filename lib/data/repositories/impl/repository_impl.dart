import 'dart:ui';

import 'package:flutter/src/foundation/basic_types.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/data/repositories/repository.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/domain/models/queue/queue.dart';

import '../../../domain/models/base/result.dart';
import '../../../domain/models/verification/Confirm.dart';
import '../../../domain/models/verification/login.dart';
import '../../../domain/models/verification/signup.dart';
import '../../../domain/models/verification/tokens.dart';

@Singleton(as: Repository)
class RepositoryImpl extends Repository {

  final ServerApi _serverApi;

  RepositoryImpl(this._serverApi);





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
  Future<Result<ContainerForList<LocationModel>>> getMyLocations(int page, int pageSize) async {
    return await _serverApi.getMyLocations(page, pageSize);
  }

  @override
  Future<Result<LocationModel>> createLocation(LocationModel location) async {
    return await _serverApi.createLocation(location);
  }

  @override
  Future<Result<LocationModel>> getLocation(int id) async {
    return await _serverApi.getLocation(id);
  }

  @override
  Future<Result> deleteLocation(int id) async {
    return await _serverApi.deleteLocation(id);
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
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize) async {
    return await _serverApi.getQueues(locationId, page, pageSize);
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
  void connectToQueueSocket(int queueId, VoidCallback onConnected, ValueChanged<QueueModel> onQueueChanged, ValueChanged onError) {
    _serverApi.connectToQueueSocket(queueId, onConnected, onQueueChanged, onError);
  }

  @override
  void disconnectFromQueueSocket(int queueId) {
    _serverApi.disconnectFromQueueSocket(queueId);
  }

}
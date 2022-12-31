import 'package:flutter/cupertino.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/verification/Confirm.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/location/location.dart';
import '../../domain/models/queue/queue.dart';
import '../../domain/models/verification/login.dart';
import '../../domain/models/verification/signup.dart';
import '../../domain/models/verification/tokens.dart';

abstract class Repository {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result<TokensModel>> login(LoginModel login);

  Future<Result<ContainerForList<LocationModel>>> getMyLocations(int page, int pageSize);
  Future<Result<LocationModel>> createLocation(LocationModel location);
  Future<Result<LocationModel>> getLocation(int id);
  Future<Result> deleteLocation(int id);

  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize);
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel location);
  Future<Result> deleteQueue(int id);
  Future<Result<QueueModel>> getQueueState(int id);
  Future<Result> serveClientInQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
  void connectToQueueSocket(int queueId, VoidCallback onConnected, ValueChanged<QueueModel> onQueueChanged, ValueChanged<dynamic> onError);
  void disconnectFromQueueSocket(int queueId);
}
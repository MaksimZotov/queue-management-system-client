import 'package:flutter/cupertino.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/verification/Confirm.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/client/client.dart';
import '../../domain/models/client/client_join_info.dart';
import '../../domain/models/location/location.dart';
import '../../domain/models/queue/queue.dart';
import '../../domain/models/verification/login.dart';
import '../../domain/models/verification/signup.dart';
import '../../domain/models/verification/tokens.dart';

abstract class Repository {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result<TokensModel>> login(LoginModel login);

  Future<Result<ContainerForList<LocationModel>>> getLocations(int page, int pageSize, String username);
  Future<Result<LocationModel>> createLocation(LocationModel location);
  Future<Result<LocationModel>> getLocation(int id, String? username);
  Future<Result> deleteLocation(int id);

  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize, String? username);
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel location);
  Future<Result> deleteQueue(int id);
  Future<Result<QueueModel>> getQueueState(int id);
  Future<Result> serveClientInQueue(int queueId, String email);
  Future<Result> notifyClientInQueue(int queueId, String email);
  void connectToQueueSocket(int queueId, VoidCallback onConnected, ValueChanged<QueueModel> onQueueChanged, ValueChanged<dynamic> onError);
  void disconnectFromQueueSocket(int queueId);

  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId);
  Future<Result<ClientModel>> joinClientToQueue(String username, int locationId, int queueId, ClientJoinInfo clientJoinInfo);
  Future<Result<ClientModel>> rejoinClientToQueue(int queueId, String email);
  Future<Result<ClientModel>> confirmClientCodeInQueue(int queueId, String email, String code);
  Future<Result<ClientModel>> leaveQueue(int queueId);
}
import 'package:flutter/cupertino.dart';

import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/client/client_join_info_model.dart';
import '../models/queue/add_client_info.dart';
import '../models/queue/client_in_queue_model.dart';
import '../models/queue/queue_model.dart';

abstract class QueueInteractor {
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String? username);
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue);
  Future<Result> deleteQueue(int id);
  Future<Result<QueueModel>> getQueueState(int id);
  Future<Result> serveClientInQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
  Future<Result<ClientInQueueModel>> addClientToQueue(int queueId, AddClientInfo addClientInfo);
}
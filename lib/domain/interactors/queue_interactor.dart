import 'package:flutter/cupertino.dart';

import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/queue/queue.dart';

abstract class QueueInteractor {
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize, String? username);
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue);
  Future<Result> deleteQueue(int id);
  Future<Result<QueueModel>> getQueueState(int id);
  Future<Result> serveClientInQueue(int queueId, String email);
  Future<Result> notifyClientInQueue(int queueId, String email);
  void connectToQueueSocket(int queueId, VoidCallback onConnected, ValueChanged<QueueModel> onQueueChanged, ValueChanged onError);
  void disconnectFromQueueSocket(int queueId);
}
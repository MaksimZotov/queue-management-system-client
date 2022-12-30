import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/queue/queue.dart';

abstract class QueueInteractor {
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize);
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue);
  Future<Result> deleteQueue(int id);
}
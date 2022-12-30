

import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/base/result.dart';
import '../../models/queue/queue.dart';
import '../queue_interactor.dart';

@Singleton(as: QueueInteractor)
class QueueInteractorImpl extends QueueInteractor {
  final Repository _repository;

  QueueInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize) async {
    return await _repository.getQueues(locationId, page, pageSize);
  }

  @override
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue) async {
    return await _repository.createQueue(locationId, queue);
  }

  @override
  Future<Result> deleteQueue(int id) async {
    return await _repository.deleteQueue(id);
  }

  @override
  Future<Result<QueueModel>> getQueueState(int id) async {
    return await _repository.getQueueState(id);
  }

  @override
  Future<Result> notifyClientInQueue(int queueId, int clientId) async {
    return await _repository.notifyClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> serveClientInQueue(int queueId, int clientId) async {
    return await _repository.serveClientInQueue(queueId, clientId);
  }
}
import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/base/result.dart';
import '../../models/queue/create_queue_request.dart';
import '../../models/queue/queue_model.dart';
import '../../models/queue/queue_state_model.dart';
import '../queue_interactor.dart';

@Singleton(as: QueueInteractor)
class QueueInteractorImpl extends QueueInteractor {
  final Repository _repository;

  QueueInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId) {
    return _repository.getQueues(locationId);
  }

  @override
  Future<Result<QueueModel>> createQueue(int locationId, CreateQueueRequest createQueueRequest) {
    return _repository.createQueue(locationId, createQueueRequest);
  }

  @override
  Future<Result> deleteQueue(int queueId) {
    return _repository.deleteQueue(queueId);
  }

  @override
  Future<Result<QueueStateModel>> getQueueState(int queueId) {
    return _repository.getQueueState(queueId);
  }
}
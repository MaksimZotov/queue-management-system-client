import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/base/result.dart';
import '../../models/location/service_model.dart';
import '../../models/queue/create_queue_request.dart';
import '../../models/queue/queue_model.dart';
import '../../models/queue/queue_state_model.dart';
import '../queue_interactor.dart';

@Singleton(as: QueueInteractor)
class QueueInteractorImpl extends QueueInteractor {
  final Repository _repository;

  QueueInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String email) {
    return _repository.getQueues(locationId, email);
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

  @override
  Future<Result> enableQueue(int queueId) {
    return _repository.enableQueue(queueId);
  }

  @override
  Future<Result> disableQueue(int queueId) {
    return _repository.disableQueue(queueId);
  }

  @override
  Future<Result> notifyClientInQueue(int queueId, int clientId) {
    return _repository.notifyClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> serveClientInQueue(int queueId, int clientId) {
    return _repository.serveClientInQueue(queueId, clientId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId) {
    return _repository.getServicesInQueue(queueId);
  }
}
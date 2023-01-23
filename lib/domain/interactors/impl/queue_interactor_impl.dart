import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/base/result.dart';
import '../../models/queue/add_client_info.dart';
import '../../models/queue/queue_model.dart';
import '../queue_interactor.dart';

@Singleton(as: QueueInteractor)
class QueueInteractorImpl extends QueueInteractor {
  final Repository _repository;

  QueueInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String username) {
    return _repository.getQueues(locationId, username);
  }

  @override
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue) {
    return _repository.createQueue(locationId, queue);
  }

  @override
  Future<Result> deleteQueue(int id) {
    return _repository.deleteQueue(id);
  }

  @override
  Future<Result<QueueModel>> getQueueState(int id) {
    return _repository.getQueueState(id);
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
  Future<Result<ClientInQueueModel>> addClientToQueue(int queueId, AddClientInfo addClientInfo) {
    return _repository.addClientToQueue(queueId, addClientInfo);
  }
}
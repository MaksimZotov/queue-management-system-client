import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';

import '../../../data/repositories/repository.dart';

@Singleton(as: ClientInteractor)
class ClientInteractorImpl extends ClientInteractor {
  final Repository _repository;

  ClientInteractorImpl(this._repository);

  @override
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId, String accessKey) {
    return _repository.getQueueStateForClient(clientId, accessKey);
  }

  @override
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey) {
    return _repository.confirmAccessKeyByClient(clientId, accessKey);
  }

  @override
  Future<Result<QueueStateForClientModel>> leaveQueue(int clientId, String accessKey) {
    return _repository.leaveQueue(clientId, accessKey);
  }
}
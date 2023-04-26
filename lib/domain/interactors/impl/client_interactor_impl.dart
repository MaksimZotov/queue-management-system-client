import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/client/create_client_request.dart';
import '../../models/client/change_client_request.dart';
import '../../models/client/client_model.dart';
import '../../models/client/serve_client_request.dart';

@Singleton(as: ClientInteractor)
class ClientInteractorImpl extends ClientInteractor {
  final Repository _repository;

  ClientInteractorImpl(this._repository);

  @override
  Future<Result<ClientModel>> createClientInLocation(int locationId, CreateClientRequest addClientRequest, String ticketNumberText) {
    return _repository.createClientInLocation(locationId, addClientRequest, ticketNumberText);
  }

  @override
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey) {
    return _repository.confirmAccessKeyByClient(clientId, accessKey);
  }

  @override
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId) {
    return _repository.getQueueStateForClient(clientId);
  }

  @override
  Future<Result> deleteClientInLocation(int locationId, int clientId) {
    return _repository.deleteClientInLocation(locationId, clientId);
  }

  @override
  Future<Result> changeClientInLocation(int locationId, int clientId, ChangeClientRequest changeClientRequest) {
    return _repository.changeClientInLocation(locationId, clientId, changeClientRequest);
  }

  @override
  Future<Result> serveClientInQueue(int queueId, int clientId, ServeClientRequest serveClientRequest) {
    return _repository.serveClientInQueue(queueId, clientId, serveClientRequest);
  }

  @override
  Future<Result> callClientInQueue(int queueId, int clientId) {
    return _repository.callClientInQueue(queueId, clientId);
  }

  @override
  Future<Result> returnClientToQueue(int queueId, int clientId) {
    return _repository.returnClientToQueue(queueId, clientId);
  }

  @override
  Future<Result> notifyClientInQueue(int queueId, int clientId) {
    return _repository.notifyClientInQueue(queueId, clientId);
  }
}
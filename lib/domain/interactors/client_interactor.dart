import '../models/base/result.dart';
import '../models/client/create_client_request.dart';
import '../models/client/change_client_request.dart';
import '../models/client/client_model.dart';
import '../models/client/queue_state_for_client_model.dart';
import '../models/client/serve_client_request.dart';

abstract class ClientInteractor {
  Future<Result<ClientModel>> createClientInLocation(int locationId, CreateClientRequest addClientRequest, String ticketNumberText);
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId);
  Future<Result> deleteClientInLocation(int locationId, int clientId);
  Future<Result> changeClientInLocation(int locationId, int clientId, ChangeClientRequest changeClientRequest);
  Future<Result> serveClientInQueue(int queueId, int clientId, ServeClientRequest serveClientRequest);
  Future<Result> callClientInQueue(int queueId, int clientId);
  Future<Result> returnClientToQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
}
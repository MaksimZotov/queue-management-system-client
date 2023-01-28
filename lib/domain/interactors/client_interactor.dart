import '../models/base/result.dart';
import '../models/client/queue_state_for_client_model.dart';

abstract class ClientInteractor {
  Future<Result<QueueStateForClientModel>> getQueueStateForClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> confirmAccessKeyByClient(int clientId, String accessKey);
  Future<Result<QueueStateForClientModel>> leaveQueue(int clientId, String accessKey);
}
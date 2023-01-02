import '../models/base/result.dart';
import '../models/client/client.dart';
import '../models/client/client_join_info.dart';

abstract class ClientInteractor {
  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId);
  Future<Result<ClientModel>> joinClientToQueue(String username, int locationId, int queueId, ClientJoinInfo clientJoinInfo);
}
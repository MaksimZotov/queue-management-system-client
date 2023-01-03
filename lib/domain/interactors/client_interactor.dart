import '../models/base/result.dart';
import '../models/client/client.dart';
import '../models/client/client_join_info.dart';

abstract class ClientInteractor {
  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId);
  Future<Result<ClientModel>> joinClientToQueue(String username, int locationId, int queueId, ClientJoinInfo clientJoinInfo);
  Future<Result<ClientModel>> rejoinClientToQueue(int queueId, String email);
  Future<Result<ClientModel>> confirmClientCodeInQueue(int queueId, String email, String code);
  Future<Result<ClientModel>> leaveQueue(int queueId);
}
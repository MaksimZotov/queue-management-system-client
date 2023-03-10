import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/service_model.dart';
import '../models/queue/create_queue_request.dart';
import '../models/queue/queue_model.dart';
import '../models/queue/queue_state_model.dart';

abstract class QueueInteractor {
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId);
  Future<Result<QueueModel>> createQueue(int locationId, CreateQueueRequest createQueueRequest);
  Future<Result> deleteQueue(int queueId);
  Future<Result<QueueStateModel>> getQueueState(int queueId);
  Future<Result> enableQueue(int queueId);
  Future<Result> disableQueue(int queueId);
  Future<Result> serveClientInQueue(int queueId, int clientId);
  Future<Result> callClientInQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInSpecialist(int specialistId);
}
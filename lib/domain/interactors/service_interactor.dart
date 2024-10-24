import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/service/create_service_request.dart';
import '../models/service/ordered_services_model.dart';
import '../models/service/service_model.dart';

abstract class ServiceInteractor {
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInSpecialist(int specialistId);
  Future<Result<OrderedServicesModel>> getServicesInServicesSequence(int servicesSequenceId);
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest);
  Future<Result> deleteServiceInLocation(int locationId, int serviceId);
}
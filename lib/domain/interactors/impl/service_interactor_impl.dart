import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/service/create_service_request.dart';
import 'package:queue_management_system_client/domain/models/service/service_model.dart';

import '../../../data/repositories/repository.dart';
import '../service_interactor.dart';

@Singleton(as: ServiceInteractor)
class ServiceInteractorImpl extends ServiceInteractor {
  final Repository _repository;

  ServiceInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId) {
    return _repository.getServicesInLocation(locationId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInQueue(int queueId) {
    return _repository.getServicesInQueue(queueId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInSpecialist(int specialistId) {
    return _repository.getServicesInSpecialist(specialistId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInServicesSequence(int servicesSequenceId) {
    return _repository.getServicesInServicesSequence(servicesSequenceId);
  }

  @override
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest) {
    return _repository.createServiceInLocation(locationId, createServiceRequest);
  }

  @override
  Future<Result> deleteServiceInLocation(int locationId, int serviceId) {
    return _repository.deleteServiceInLocation(locationId, serviceId);
  }
}
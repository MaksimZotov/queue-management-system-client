import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/check_is_owner_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/client/add_client_request.dart';
import '../../models/location/create_location_request.dart';
import '../../models/location/create_specialist_request.dart';
import '../../models/location/create_service_request.dart';
import '../../models/location/create_services_sequence_request.dart';
import '../../models/location/specialist_model.dart';
import '../../models/location/service_model.dart';
import '../../models/location/services_sequence_model.dart';

@Singleton(as: LocationInteractor)
class LocationInteractorImpl extends LocationInteractor {
  final Repository _repository;

  LocationInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(int? accountId) async {
    return _repository.getLocations(accountId);
  }

  @override
  Future<Result<CheckIsOwnerModel>> checkIsOwner(int? accountId) {
    return _repository.checkIsOwner(accountId);
  }

  @override
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest) {
    return _repository.createLocation(createLocationRequest);
  }

  @override
  Future<Result> deleteLocation(int locationId) {
    return _repository.deleteLocation(locationId);
  }

  @override
  Future<Result<LocationModel>> getLocation(int locationId) {
    return _repository.getLocation(locationId);
  }

  @override
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId) {
    return _repository.getServicesInLocation(locationId);
  }

  @override
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest) {
    return _repository.createServiceInLocation(locationId, createServiceRequest);
  }

  @override
  Future<Result> deleteServiceInLocation(int locationId, int serviceId) {
    return _repository.deleteServiceInLocation(locationId, serviceId);
  }

  @override
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId) {
    return _repository.getServicesSequencesInLocation(locationId);
  }

  @override
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest) {
    return _repository.createServicesSequenceInLocation(locationId, createServicesSequenceRequest);
  }

  @override
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence) {
    return _repository.deleteServicesSequenceInLocation(locationId, servicesSequence);
  }

  @override
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId) {
    return _repository.getSpecialistsInLocation(locationId);
  }

  @override
  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest) {
    return _repository.createSpecialistInLocation(locationId, createSpecialistRequest);
  }

  @override
  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId) {
    return _repository.deleteSpecialistInLocation(locationId, specialistId);
  }

  @override
  Future<Result> enableLocation(int locationId) {
    return _repository.enableLocation(locationId);
  }

  @override
  Future<Result> disableLocation(int locationId) {
    return _repository.disableLocation(locationId);
  }

  @override
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest) {
    return _repository.addClientInLocation(locationId, addClientRequest);
  }
}
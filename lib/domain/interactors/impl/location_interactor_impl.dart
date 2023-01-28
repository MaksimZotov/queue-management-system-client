import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/has_rights_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/client/add_client_request.dart';
import '../../models/location/board_model.dart';
import '../../models/location/create_location_request.dart';
import '../../models/location/create_queue_type_request.dart';
import '../../models/location/create_service_request.dart';
import '../../models/location/create_services_sequence_request.dart';
import '../../models/location/queue_type_model.dart';
import '../../models/location/service_model.dart';
import '../../models/location/services_sequence_model.dart';

@Singleton(as: LocationInteractor)
class LocationInteractorImpl extends LocationInteractor {
  final Repository _repository;

  LocationInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(String? username) async {
    return _repository.getLocations(username);
  }

  @override
  Future<Result<HasRightsModel>> checkHasRights(String? username) {
    return _repository.checkHasRights(username);
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
  Future<Result<LocationModel>> getLocation(int locationId, String? username) {
    return _repository.getLocation(locationId, username);
  }

  @override
  Future<Result<LocationModel>> changeMaxColumns(int locationId, int maxColumns) {
    return _repository.changeMaxColumns(locationId, maxColumns);
  }

  @override
  Future<Result<BoardModel>> getLocationBoard(int locationId) {
    return _repository.getLocationBoard(locationId);
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
  Future<Result<ContainerForList<QueueTypeModel>>> getQueueTypesInLocation(int locationId) {
    return _repository.getQueueTypesInLocation(locationId);
  }

  @override
  Future<Result<QueueTypeModel>> createQueueTypeInLocation(int locationId, CreateQueueTypeRequest createQueueTypeRequest) {
    return _repository.createQueueTypeInLocation(locationId, createQueueTypeRequest);
  }

  @override
  Future<Result> deleteQueueTypeInLocation(int locationId, int queueTypeId) {
    return _repository.deleteQueueTypeInLocation(locationId, queueTypeId);
  }

  @override
  Future<Result> pauseLocation(int locationId) {
    return _repository.pauseLocation(locationId);
  }

  @override
  Future<Result> startLocation(int locationId) {
    return _repository.startLocation(locationId);
  }

  @override
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest) {
    return _repository.addClientInLocation(locationId, addClientRequest);
  }
}
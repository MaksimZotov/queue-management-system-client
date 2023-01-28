import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/client/add_client_request.dart';
import '../models/location/board_model.dart';
import '../models/location/create_location_request.dart';
import '../models/location/create_queue_type_request.dart';
import '../models/location/create_service_request.dart';
import '../models/location/create_services_sequence_request.dart';
import '../models/location/has_rights_model.dart';
import '../models/location/location_model.dart';
import '../models/location/queue_type_model.dart';
import '../models/location/service_model.dart';
import '../models/location/services_sequence_model.dart';

abstract class LocationInteractor {
  Future<Result<ContainerForList<LocationModel>>> getLocations(String? username);
  Future<Result<HasRightsModel>> checkHasRights(String? username);
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest);
  Future<Result> deleteLocation(int locationId);
  Future<Result<LocationModel>> getLocation(int locationId, String? username);
  Future<Result<LocationModel>> changeMaxColumns(int locationId, int maxColumns);
  Future<Result<BoardModel>> getLocationBoard(int locationId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId);
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest);
  Future<Result> deleteServiceInLocation(int locationId, int serviceId);
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId);
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest);
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence);
  Future<Result<ContainerForList<QueueTypeModel>>> getQueueTypesInLocation(int locationId);
  Future<Result<QueueTypeModel>> createQueueTypeInLocation(int locationId, CreateQueueTypeRequest createQueueTypeRequest);
  Future<Result> deleteQueueTypeInLocation(int locationId, int queueTypeId);
  Future<Result> pauseLocation(int locationId);
  Future<Result> startLocation(int locationId);
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest);
}
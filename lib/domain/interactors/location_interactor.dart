import 'package:queue_management_system_client/domain/models/client/change_client_request.dart';

import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/client/add_client_request.dart';
import '../models/location/create_location_request.dart';
import '../models/location/create_specialist_request.dart';
import '../models/location/create_service_request.dart';
import '../models/location/create_services_sequence_request.dart';
import '../models/location/check_is_owner_model.dart';
import '../models/location/location_model.dart';
import '../models/location/specialist_model.dart';
import '../models/location/service_model.dart';
import '../models/location/services_sequence_model.dart';
import '../models/locationnew/location_state.dart';

abstract class LocationInteractor {
  Future<Result<ContainerForList<LocationModel>>> getLocations(int? accountId);
  Future<Result<CheckIsOwnerModel>> checkIsOwner(int? accountId);
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest);
  Future<Result> deleteLocation(int locationId);
  Future<Result<LocationModel>> getLocation(int locationId);
  Future<Result<LocationState>> getLocationState(int locationId);
  Future<Result<ContainerForList<ServiceModel>>> getServicesInLocation(int locationId);
  Future<Result<ServiceModel>> createServiceInLocation(int locationId, CreateServiceRequest createServiceRequest);
  Future<Result> deleteServiceInLocation(int locationId, int serviceId);
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId);
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest);
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence);
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId);
  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest);
  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId);
  Future<Result> addClientInLocation(int locationId, AddClientRequest addClientRequest);
  Future<Result> changeClientInLocation(int locationId, ChangeClientRequest changeClientRequest);
}
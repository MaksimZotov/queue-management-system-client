import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/create_location_request.dart';
import '../models/location/check_is_owner_model.dart';
import '../models/location/location_model.dart';
import '../models/location/location_state.dart';

abstract class LocationInteractor {
  Future<Result<ContainerForList<LocationModel>>> getLocations(int? accountId);
  Future<Result<CheckIsOwnerModel>> checkIsOwner(int? accountId);
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest);
  Future<Result> deleteLocation(int locationId);
  Future<Result<LocationModel>> getLocation(int locationId);
  Future<Result<LocationState>> getLocationState(int locationId);
}
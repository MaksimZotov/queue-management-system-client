import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/has_rights_model.dart';
import '../models/location/location_model.dart';

abstract class LocationInteractor {
  Future<Result<ContainerForList<LocationModel>>> getLocations(String? username);
  Future<Result<LocationModel>> createLocation(LocationModel location);
  Future<Result<LocationModel>> getLocation(int id, String? username);
  Future<Result> deleteLocation(int locationId);
  Future<Result<HasRightsModel>> checkHasRights(String? username);
}
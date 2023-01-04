import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/location_model.dart';

abstract class LocationInteractor {
  Future<Result<ContainerForList<LocationModel>>> getLocations(int page, int pageSize, String username);
  Future<Result<LocationModel>> createLocation(LocationModel location);
  Future<Result<LocationModel>> getLocation(int id, String? username);
  Future<Result> deleteLocation(int id);
}
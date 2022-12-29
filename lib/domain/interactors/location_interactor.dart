import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/location.dart';

abstract class LocationInteractor {
  Future<Result<ContainerForList<LocationModel>>> getMyLocations(int page, int pageSize);
  Future<Result<LocationModel>> createLocation(LocationModel location);
  Future<Result> deleteLocation(int id);
}
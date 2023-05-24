import 'package:queue_management_system_client/domain/models/location/change/base/location_change_model.dart';

import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/create_location_request.dart';
import '../models/location/location_model.dart';
import '../models/location/state/location_state.dart';

abstract class LocationInteractor {
  Future<Result<ContainerForList<LocationModel>>> getLocations(int? accountId);
  Future<Result<LocationModel>> createLocation(CreateLocationRequest createLocationRequest);
  Future<Result> deleteLocation(int locationId);
  Future<Result<LocationModel>> getLocation(int locationId);
  Future<Result<LocationState>> getLocationState(int locationId);
  LocationState transformLocation(LocationState prevState, List<LocationChange> changes);
}
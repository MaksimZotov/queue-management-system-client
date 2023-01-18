import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/has_rights_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';

@Singleton(as: LocationInteractor)
class LocationInteractorImpl extends LocationInteractor {
  final Repository _repository;

  LocationInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(String? username) async {
    return await _repository.getLocations(username);
  }

  @override
  Future<Result<LocationModel>> createLocation(LocationModel location) async {
    return await _repository.createLocation(location);
  }

  @override
  Future<Result<LocationModel>> getLocation(int id, String? username) async {
    return await _repository.getLocation(id, username);
  }

  @override
  Future<Result> deleteLocation(int locationId) async {
    return await _repository.deleteLocation(locationId);
  }

  @override
  Future<Result<HasRightsModel>> checkHasRights(String? username) async {
    return await _repository.checkHasRights(username);
  }
}
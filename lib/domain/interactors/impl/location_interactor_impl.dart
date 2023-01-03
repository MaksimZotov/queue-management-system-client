import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';

@Singleton(as: LocationInteractor)
class LocationInteractorImpl extends LocationInteractor {
  final Repository _repository;

  LocationInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(int page, int pageSize, String username) async {
    return await _repository.getLocations(page, pageSize, username);
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
  Future<Result> deleteLocation(int id) async {
    return await _repository.deleteLocation(id);
  }
}
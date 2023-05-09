import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/change/base/location_change_model.dart';
import 'package:queue_management_system_client/domain/models/location/change/location_add_client.dart';
import 'package:queue_management_system_client/domain/models/location/change/location_delete_client.dart';
import 'package:queue_management_system_client/domain/models/location/change/location_update_client.dart';
import 'package:queue_management_system_client/domain/models/location/check_is_owner_model.dart';
import 'package:queue_management_system_client/domain/models/location/client.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/location/create_location_request.dart';
import '../../models/location/location_state.dart';

@Singleton(as: LocationInteractor)
class LocationInteractorImpl extends LocationInteractor {
  final Repository _repository;

  LocationInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<LocationModel>>> getLocations(int? accountId) async {
    return _repository.getLocations(accountId);
  }

  @override
  Future<Result<CheckIsOwnerModel>> checkIsOwner(int? accountId) {
    return _repository.checkIsOwner(accountId);
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
  Future<Result<LocationModel>> getLocation(int locationId) {
    return _repository.getLocation(locationId);
  }

  @override
  Future<Result<LocationState>> getLocationState(int locationId) {
    return _repository.getLocationState(locationId);
  }

  @override
  LocationState transformLocation(LocationState prevState, List<LocationChange> changes) {
    LocationState state = prevState;
    for (LocationChange change in changes) {
      state = _transformLocation(state, change);
    }
    return state;
  }

  LocationState _transformLocation(LocationState prevState, LocationChange change) {
    List<Client> clients = prevState.clients.toList();

    if (change is LocationAddClient) {
      clients.removeWhere((client) => client.id == change.client.id);
      clients.add(change.client);
      return prevState.copy(
        clients: clients
      );
    }

    if (change is LocationUpdateClient) {
      return prevState.copy(
        clients: clients
            .map((client) => _mapClientUpdate(client, change))
            .toList()
      );
    }

    if (change is LocationDeleteClient) {
      clients.removeWhere((client) => client.id == change.clientId);
      return prevState.copy(
          clients: clients
      );
    }

    return prevState;
  }

  Client _mapClientUpdate(Client client, LocationUpdateClient locationUpdateClient) {
    if (client.id == locationUpdateClient.client.id) {
      return locationUpdateClient.client;
    } else {
      return client;
    }
  }
}
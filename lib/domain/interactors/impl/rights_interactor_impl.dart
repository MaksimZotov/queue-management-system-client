import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/board_interactor.dart';
import 'package:queue_management_system_client/domain/interactors/rights_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/board/board_model.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';

@Singleton(as: RightsInteractor)
class RightsInteractorImpl extends RightsInteractor {
  final Repository _repository;

  RightsInteractorImpl(this._repository);

  @override
  Future<Result> addRights(int locationId, String email) {
    return _repository.addRights(locationId, email);
  }

  @override
  Future<Result> deleteRights(int locationId, String email) {
    return _repository.deleteRights(locationId, email);
  }

  @override
  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId) {
    return _repository.getRights(locationId);
  }

}
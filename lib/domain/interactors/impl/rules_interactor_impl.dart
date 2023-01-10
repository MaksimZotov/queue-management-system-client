import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/board_interactor.dart';
import 'package:queue_management_system_client/domain/interactors/rules_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/board/board_model.dart';
import 'package:queue_management_system_client/domain/models/rules/rules_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';

@Singleton(as: RulesInteractor)
class RulesInteractorImpl extends RulesInteractor {
  final Repository _repository;

  RulesInteractorImpl(this._repository);

  @override
  Future<Result> addRules(int locationId, String email) {
    return _repository.addRules(locationId, email);
  }

  @override
  Future<Result> deleteRules(int locationId, String email) {
    return _repository.deleteRules(locationId, email);
  }

  @override
  Future<Result<ContainerForList<RulesModel>>> getRules(int locationId) {
    return _repository.getRules(locationId);
  }

}
import 'package:queue_management_system_client/domain/models/rules/rules_model.dart';

import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/board/board_model.dart';

abstract class RulesInteractor {
  Future<Result<ContainerForList<RulesModel>>> getRules(int locationId);
  Future<Result> addRules(int locationId, String email);
  Future<Result> deleteRules(int locationId, String email);
}
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';

import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/board/board_model.dart';

abstract class RightsInteractor {
  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId);
  Future<Result> addRights(int locationId, String email);
  Future<Result> deleteRights(int locationId, String email);
}
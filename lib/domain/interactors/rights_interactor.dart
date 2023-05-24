import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';

import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/rights/add_rights_request.dart';

abstract class RightsInteractor {
  Future<Result<ContainerForList<RightsModel>>> getRights(int locationId);
  Future<Result> addRights(int locationId, AddRightsRequest addRightsRequest);
  Future<Result> deleteRights(int locationId, String email);
}
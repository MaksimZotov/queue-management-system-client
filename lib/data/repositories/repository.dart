import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/verification/Confirm.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/location/location.dart';
import '../../domain/models/verification/login.dart';
import '../../domain/models/verification/signup.dart';
import '../../domain/models/verification/tokens.dart';

abstract class Repository {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result<TokensModel>> login(LoginModel login);

  Future<Result<ContainerForList<LocationModel>>> getMyLocations(int page, int pageSize);
  Future<Result<LocationModel>> createLocation(LocationModel location);
  Future<Result> deleteLocation(int id);
}
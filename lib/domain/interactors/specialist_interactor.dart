import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/create_specialist_request.dart';
import '../models/location/specialist_model.dart';

abstract class SpecialistInteractor {
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId);
  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest);
  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId);
}
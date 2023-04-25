import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/create_specialist_request.dart';
import 'package:queue_management_system_client/domain/models/location/specialist_model.dart';

import '../../../data/repositories/repository.dart';
import '../specialist_interactor.dart';

@Singleton(as: SpecialistInteractor)
class SpecialistInteractorImpl extends SpecialistInteractor {
  final Repository _repository;

  SpecialistInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<SpecialistModel>>> getSpecialistsInLocation(int locationId) {
    return _repository.getSpecialistsInLocation(locationId);
  }

  @override
  Future<Result<SpecialistModel>> createSpecialistInLocation(int locationId, CreateSpecialistRequest createSpecialistRequest) {
    return _repository.createSpecialistInLocation(locationId, createSpecialistRequest);
  }

  @override
  Future<Result> deleteSpecialistInLocation(int locationId, int specialistId) {
    return _repository.deleteSpecialistInLocation(locationId, specialistId);
  }
}
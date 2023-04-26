import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/sequence/create_services_sequence_request.dart';
import 'package:queue_management_system_client/domain/models/sequence/services_sequence_model.dart';

import '../../../data/repositories/repository.dart';
import '../services_sequence_interactor.dart';

@Singleton(as: ServicesSequenceInteractor)
class ServicesSequenceInteractorImpl extends ServicesSequenceInteractor {
  final Repository _repository;

  ServicesSequenceInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId) {
    return _repository.getServicesSequencesInLocation(locationId);
  }

  @override
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest) {
    return _repository.createServicesSequenceInLocation(locationId, createServicesSequenceRequest);
  }

  @override
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence) {
    return _repository.deleteServicesSequenceInLocation(locationId, servicesSequence);
  }
}
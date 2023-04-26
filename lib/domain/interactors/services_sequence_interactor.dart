import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/sequence/create_services_sequence_request.dart';
import '../models/sequence/services_sequence_model.dart';

abstract class ServicesSequenceInteractor {
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId);
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest);
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence);
}
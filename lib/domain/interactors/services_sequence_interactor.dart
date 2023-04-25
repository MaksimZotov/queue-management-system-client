import '../models/base/container_for_list.dart';
import '../models/base/result.dart';
import '../models/location/create_services_sequence_request.dart';
import '../models/location/services_sequence_model.dart';

abstract class ServicesSequenceInteractor {
  Future<Result<ContainerForList<ServicesSequenceModel>>> getServicesSequencesInLocation(int locationId);
  Future<Result<ServicesSequenceModel>> createServicesSequenceInLocation(int locationId, CreateServicesSequenceRequest createServicesSequenceRequest);
  Future<Result> deleteServicesSequenceInLocation(int locationId, int servicesSequence);
}
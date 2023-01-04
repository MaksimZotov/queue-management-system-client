import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/client/client_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/client/client_join_info_model.dart';

@Singleton(as: ClientInteractor)
class ClientInteractorImpl extends ClientInteractor {
  final Repository _repository;

  ClientInteractorImpl(this._repository);

  @override
  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId) async {
    return await _repository.getClientInQueue(username, locationId, queueId);
  }

  @override
  Future<Result<ClientModel>> joinClientToQueue(String username, int locationId, int queueId, ClientJoinInfo clientJoinInfo) async {
    return await _repository.joinClientToQueue(username, locationId, queueId, clientJoinInfo);
  }

  @override
  Future<Result<ClientModel>> confirmClientCodeInQueue(int queueId, String email, String code) async {
    return await _repository.confirmClientCodeInQueue(queueId, email, code);
  }

  @override
  Future<Result<ClientModel>> leaveQueue(int queueId) async {
    return await _repository.leaveQueue(queueId);
  }

  @override
  Future<Result<ClientModel>> rejoinClientToQueue(int queueId, String email) async {
    return await _repository.rejoinClientToQueue(queueId, email);
  }
}
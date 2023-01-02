import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/client/client.dart';

import '../../../data/repositories/repository.dart';
import '../../models/client/client_join_info.dart';

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
}
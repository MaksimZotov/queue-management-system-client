import 'package:flutter/cupertino.dart';
import 'package:queue_management_system_client/domain/models/base/container_for_list.dart';
import 'package:queue_management_system_client/domain/models/verification/confirm_model.dart';

import '../../domain/models/base/result.dart';
import '../../domain/models/board/board_model.dart';
import '../../domain/models/client/client_model.dart';
import '../../domain/models/client/client_join_info_model.dart';
import '../../domain/models/location/has_rules_model.dart';
import '../../domain/models/location/location_model.dart';
import '../../domain/models/queue/add_client_info.dart';
import '../../domain/models/queue/client_in_queue_model.dart';
import '../../domain/models/queue/queue_model.dart';
import '../../domain/models/rules/rules_model.dart';
import '../../domain/models/verification/login_model.dart';
import '../../domain/models/verification/signup_model.dart';
import '../../domain/models/verification/tokens_model.dart';

abstract class Repository {
  Future<Result> signup(SignupModel signup);
  Future<Result> confirm(ConfirmModel confirm);
  Future<Result<TokensModel>> login(LoginModel login);
  Future<bool> checkToken();
  Future logout();

  Future<Result<ContainerForList<LocationModel>>> getLocations(String username);
  Future<Result<LocationModel>> createLocation(LocationModel location);
  Future<Result<LocationModel>> getLocation(int id, String? username);
  Future<Result> deleteLocation(int locationId);
  Future<Result<HasRulesModel>> checkHasRules(String username);

  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, String? username);
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel location);
  Future<Result> deleteQueue(int id);
  Future<Result<QueueModel>> getQueueState(int id);
  Future<Result> serveClientInQueue(int queueId, int clientId);
  Future<Result> notifyClientInQueue(int queueId, int clientId);
  Future<Result<ClientInQueueModel>> addClientToQueue(int queueId, AddClientInfo addClientInfo);

  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError);
  void disconnectFromQueueSocket(String destination);

  Future<Result<ClientModel>> getClientInQueue(String username, int locationId, int queueId);
  Future<Result<ClientModel>> joinClientToQueue(String username, int locationId, int queueId, ClientJoinInfo clientJoinInfo);
  Future<Result<ClientModel>> rejoinClientToQueue(int queueId, String email);
  Future<Result<ClientModel>> confirmClientCodeInQueue(int queueId, String email, String code);
  Future<Result<ClientModel>> leaveQueue(int queueId);

  Future<Result<BoardModel>> getBoard(int locationId);

  Future<Result<ContainerForList<RulesModel>>> getRules(int locationId);
  Future<Result> addRules(int locationId, String email);
  Future<Result> deleteRules(int locationId, String email);
}
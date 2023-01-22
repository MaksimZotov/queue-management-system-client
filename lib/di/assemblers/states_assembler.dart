import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/board/board_screen.dart';
import 'package:queue_management_system_client/ui/screens/client/client_screen.dart';
import 'package:queue_management_system_client/ui/screens/client/client_confirm_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_join_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/queue/add_client_dialog.dart';
import 'package:queue_management_system_client/ui/screens/queue/queue_screen.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/add_rule_dialog.dart';
import 'package:queue_management_system_client/ui/screens/account/authorization_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/registration_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/select_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/delete_rule_dialog.dart';

import '../../ui/screens/client/client_rejoin_dialog.dart';
import '../../ui/screens/location/locations_screen.dart';
import '../../ui/screens/queue/create_queue_dialog.dart';
import '../../ui/screens/queue/delete_queue_dialog.dart';
import '../../ui/screens/rights/rights_screen.dart';
import '../../ui/screens/account/confirm_dialog.dart';
import '../main/main.dart';

class StatesAssembler {
  const StatesAssembler._();

  SelectCubit getSelectCubit() => getIt.get();
  RegistrationCubit getRegistrationCubit() => getIt.get();
  ConfirmCubit getConfirmCubit() => getIt.get();
  AuthorizationCubit getAuthorizationCubit() => getIt.get();

  LocationsCubit getLocationsCubit(LocationsConfig config) => getIt.get(param1: config);
  CreateLocationCubit getCreateLocationCubit() => getIt.get();
  DeleteLocationCubit getDeleteLocationCubit() => getIt.get();

  QueuesCubit getQueuesCubit(QueuesConfig config) => getIt.get(param1: config);
  CreateQueueCubit getCreateQueueCubit() => getIt.get();
  DeleteQueueCubit getDeleteQueueCubit() => getIt.get();
  QueueCubit getQueueCubit(QueueConfig config) => getIt.get(param1: config);
  AddClientCubit getAddClientCubit() => getIt.get();

  ClientCubit getClientCubit(ClientConfig config) => getIt.get(param1: config);
  ClientJoinCubit getClientJoinCubit() => getIt.get();
  ClientRejoinCubit getClientRejoinCubit() => getIt.get();
  ClientConfirmCubit getClientConfirmCubit() => getIt.get();

  BoardCubit getBoardCubit(BoardConfig config) => getIt.get(param1: config);

  RightsCubit getRightsCubit(RightsConfig config) => getIt.get(param1: config);
  AddRuleCubit getAddRuleCubit() => getIt.get();
  DeleteRuleCubit getDeleteRuleCubit() => getIt.get();
}

const statesAssembler = StatesAssembler._();
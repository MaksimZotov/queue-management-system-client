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
import 'package:queue_management_system_client/ui/screens/rights/add_right_dialog.dart';
import 'package:queue_management_system_client/ui/screens/account/authorization_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/registration_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/initial_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/delete_right_dialog.dart';

import '../../ui/screens/client/client_rejoin_dialog.dart';
import '../../ui/screens/location/locations_screen.dart';
import '../../ui/screens/queue/create_queue_dialog.dart';
import '../../ui/screens/queue/delete_queue_dialog.dart';
import '../../ui/screens/rights/rights_screen.dart';
import '../../ui/screens/account/confirm_registration_dialog.dart';
import '../main/main.dart';

class StatesAssembler {
  const StatesAssembler._();

  SelectCubit getSelectCubit() => getIt.get();
  RegistrationCubit getRegistrationCubit() => getIt.get();
  ConfirmRegistrationCubit getConfirmRegistrationCubit(ConfirmRegistrationConfig config) => getIt.get(param1: config);
  AuthorizationCubit getAuthorizationCubit() => getIt.get();

  LocationsCubit getLocationsCubit(LocationsConfig config) => getIt.get(param1: config);
  CreateLocationCubit getCreateLocationCubit(CreateLocationConfig config) => getIt.get(param1: config);
  DeleteLocationCubit getDeleteLocationCubit(DeleteLocationConfig config) => getIt.get(param1: config);

  QueuesCubit getQueuesCubit(QueuesConfig config) => getIt.get(param1: config);
  CreateQueueCubit getCreateQueueCubit(CreateQueueConfig config) => getIt.get(param1: config);
  DeleteQueueCubit getDeleteQueueCubit(DeleteQueueConfig config) => getIt.get(param1: config);
  QueueCubit getQueueCubit(QueueConfig config) => getIt.get(param1: config);
  AddClientCubit getAddClientCubit(AddClientConfig config) => getIt.get(param1: config);

  ClientCubit getClientCubit(ClientConfig config) => getIt.get(param1: config);
  ClientJoinCubit getClientJoinCubit(ClientJoinConfig config) => getIt.get(param1: config);
  ClientRejoinCubit getClientRejoinCubit(ClientRejoinConfig config) => getIt.get(param1: config);
  ClientConfirmCubit getClientConfirmCubit(ClientConfirmConfig config) => getIt.get(param1: config);

  BoardCubit getBoardCubit(BoardConfig config) => getIt.get(param1: config);

  RightsCubit getRightsCubit(RightsConfig config) => getIt.get(param1: config);
  AddRightCubit getAddRightCubit(AddRightConfig config) => getIt.get(param1: config);
  DeleteRightCubit getDeleteRightCubit(DeleteRightConfig config) => getIt.get(param1: config);
}

const statesAssembler = StatesAssembler._();
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/client/client.dart';
import 'package:queue_management_system_client/ui/screens/client/client_join.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location.dart';
import 'package:queue_management_system_client/ui/screens/queue/queue.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues.dart';
import 'package:queue_management_system_client/ui/screens/verification/authorization.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/screens/verification/select.dart';

import '../../ui/screens/location/locations.dart';
import '../../ui/screens/queue/create_queue.dart';
import '../../ui/screens/verification/confirmation.dart';
import '../main/main.dart';

class StatesAssembler {
  const StatesAssembler._();

  SelectCubit getSelectCubit() => getIt.get();
  RegistrationCubit getRegistrationCubit() => getIt.get();
  ConfirmationCubit getConfirmationCubit(ConfirmationConfig params) => getIt.get(param1: params);
  AuthorizationCubit getAuthorizationCubit() => getIt.get();

  LocationsCubit getLocationsCubit(LocationsConfig config) => getIt.get(param1: config);
  CreateLocationCubit getCreateLocationCubit() => getIt.get();

  QueuesCubit getQueuesCubit(QueuesConfig config) => getIt.get(param1: config);
  CreateQueueCubit getCreateQueueCubit() => getIt.get();
  QueueCubit getQueueCubit(QueueConfig config) => getIt.get(param1: config);

  ClientCubit getClientCubit(ClientConfig config) => getIt.get(param1: config);
  ClientJoinCubit getClientJoinCubit() => getIt.get();
}

const statesAssembler = StatesAssembler._();
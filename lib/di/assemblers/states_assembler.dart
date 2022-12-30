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
  ConfirmationCubit getConfirmationCubit(ConfirmationParams params) => getIt.get(param1: params);
  AuthorizationCubit getAuthorizationCubit() => getIt.get();

  LocationsCubit getLocationsCubit(LocationsParams params) => getIt.get(param1: params);
  CreateLocationCubit getCreateLocationCubit() => getIt.get();

  QueuesCubit getQueuesCubit(QueuesParams params) => getIt.get(param1: params);
  CreateQueueCubit getCreateQueueCubit() => getIt.get();
  QueueCubit getQueueCubit(QueueParams params) => getIt.get(param1: params);
}

const statesAssembler = StatesAssembler._();
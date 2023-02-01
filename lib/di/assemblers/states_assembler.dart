import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/board/board_screen.dart';
import 'package:queue_management_system_client/ui/screens/client/client_screen.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/search_locations_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/switch_to_terminal_mode_dialog.dart';
import 'package:queue_management_system_client/ui/screens/queue/queue_screen.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/add_right_dialog.dart';
import 'package:queue_management_system_client/ui/screens/account/authorization_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/registration_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/delete_right_dialog.dart';
import 'package:queue_management_system_client/ui/screens/sequence/create_services_sequence_dialog.dart';
import 'package:queue_management_system_client/ui/screens/sequence/delete_services_sequence_dialog.dart';
import 'package:queue_management_system_client/ui/screens/sequence/services_sequence_screen.dart';
import 'package:queue_management_system_client/ui/screens/service/services_screen.dart';
import 'package:queue_management_system_client/ui/screens/type/delete_queue_type_dialog.dart';
import 'package:queue_management_system_client/ui/screens/type/queue_types_screen.dart';

import '../../ui/screens/account/initial_screen.dart';
import '../../ui/screens/location/location_screen.dart';
import '../../ui/screens/location/locations_screen.dart';
import '../../ui/screens/queue/create_queue_dialog.dart';
import '../../ui/screens/queue/delete_queue_dialog.dart';
import '../../ui/screens/rights/rights_screen.dart';
import '../../ui/screens/account/confirm_registration_dialog.dart';
import '../../ui/screens/service/create_service_dialog.dart';
import '../../ui/screens/service/delete_service_dialog.dart';
import '../../ui/screens/type/create_queue_type_dialog.dart';
import '../main/main.dart';

class StatesAssembler {
  const StatesAssembler._();

  InitialCubit getInitialCubit() => getIt.get();
  RegistrationCubit getRegistrationCubit() => getIt.get();
  ConfirmRegistrationCubit getConfirmRegistrationCubit(ConfirmRegistrationConfig config) => getIt.get(param1: config);
  AuthorizationCubit getAuthorizationCubit() => getIt.get();

  LocationsCubit getLocationsCubit(LocationsConfig config) => getIt.get(param1: config);
  LocationCubit getLocationCubit(LocationConfig config) => getIt.get(param1: config);
  CreateLocationCubit getCreateLocationCubit(CreateLocationConfig config) => getIt.get(param1: config);
  DeleteLocationCubit getDeleteLocationCubit(DeleteLocationConfig config) => getIt.get(param1: config);
  SearchLocationsCubit getSearchLocationsCubit(SearchLocationsConfig config) => getIt.get(param1: config);

  QueuesCubit getQueuesCubit(QueuesConfig config) => getIt.get(param1: config);
  CreateQueueCubit getCreateQueueCubit(CreateQueueConfig config) => getIt.get(param1: config);
  DeleteQueueCubit getDeleteQueueCubit(DeleteQueueConfig config) => getIt.get(param1: config);
  QueueCubit getQueueCubit(QueueConfig config) => getIt.get(param1: config);

  ServicesSequencesCubit getServicesSequencesCubit(ServicesSequencesConfig config) => getIt.get(param1: config);
  CreateServicesSequenceCubit getCreateServicesSequenceCubit(CreateServicesSequenceConfig config) => getIt.get(param1: config);
  DeleteServicesSequenceCubit getDeleteServicesSequenceCubit(DeleteServicesSequenceConfig config) => getIt.get(param1: config);

  ServicesCubit getServicesCubit(ServicesConfig config) => getIt.get(param1: config);
  CreateServiceCubit getCreateServiceCubit(CreateServiceConfig config) => getIt.get(param1: config);
  DeleteServiceCubit getDeleteServiceCubit(DeleteServiceConfig config) => getIt.get(param1: config);

  QueueTypesCubit getQueueTypesCubit(QueueTypesConfig config) => getIt.get(param1: config);
  CreateQueueTypeCubit getCreateQueueTypeCubit(CreateQueueTypeConfig config) => getIt.get(param1: config);
  DeleteQueueTypeCubit getDeleteQueueTypeCubit(DeleteQueueTypeConfig config) => getIt.get(param1: config);

  ClientCubit getClientCubit(ClientConfig config) => getIt.get(param1: config);

  BoardCubit getBoardCubit(BoardConfig config) => getIt.get(param1: config);

  RightsCubit getRightsCubit(RightsConfig config) => getIt.get(param1: config);
  AddRightCubit getAddRightCubit(AddRightConfig config) => getIt.get(param1: config);
  DeleteRightCubit getDeleteRightCubit(DeleteRightConfig config) => getIt.get(param1: config);

  SwitchToTerminalModeCubit getSwitchToTerminalModeCubit(SwitchToTerminalModeConfig config) => getIt.get(param1: config);
}

const statesAssembler = StatesAssembler._();
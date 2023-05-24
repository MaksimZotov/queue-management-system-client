import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/board/board_screen.dart';
import 'package:queue_management_system_client/ui/screens/client/create_client_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_screen.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/logout_from_account_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/navigation_to_another_owner.dart';
import 'package:queue_management_system_client/ui/screens/location/switch_to_kiosk_dialog.dart';
import 'package:queue_management_system_client/ui/screens/queue/queue_screen.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/add_rights_dialog.dart';
import 'package:queue_management_system_client/ui/screens/account/authorization_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/registration_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/delete_rights_dialog.dart';
import 'package:queue_management_system_client/ui/screens/sequence/create_services_sequence_dialog.dart';
import 'package:queue_management_system_client/ui/screens/sequence/delete_services_sequence_dialog.dart';
import 'package:queue_management_system_client/ui/screens/sequence/services_sequence_screen.dart';
import 'package:queue_management_system_client/ui/screens/service/services_screen.dart';

import '../../ui/screens/account/initial_screen.dart';
import '../../ui/screens/location/location_screen.dart';
import '../../ui/screens/location/locations_screen.dart';
import '../../ui/screens/location/switch_to_board_dialog.dart';
import '../../ui/screens/queue/create_queue_dialog.dart';
import '../../ui/screens/queue/delete_queue_dialog.dart';
import '../../ui/screens/rights/rights_screen.dart';
import '../../ui/screens/account/confirm_registration_dialog.dart';
import '../../ui/screens/service/create_service_dialog.dart';
import '../../ui/screens/service/delete_service_dialog.dart';
import '../../ui/screens/specialist/create_specialist_dialog.dart';
import '../../ui/screens/specialist/delete_specialist_dialog.dart';
import '../../ui/screens/specialist/specialists_screen.dart';
import '../main/main.dart';

class StatesAssembler {
  const StatesAssembler._();

  InitialCubit getInitialCubit(InitialConfig config) => getIt.get(param1: config);
  RegistrationCubit getRegistrationCubit() => getIt.get();
  ConfirmRegistrationCubit getConfirmRegistrationCubit(ConfirmRegistrationConfig config) => getIt.get(param1: config);
  AuthorizationCubit getAuthorizationCubit() => getIt.get();

  LocationsCubit getLocationsCubit(LocationsConfig config) => getIt.get(param1: config);
  LocationCubit getLocationCubit(LocationConfig config) => getIt.get(param1: config);
  CreateLocationCubit getCreateLocationCubit(CreateLocationConfig config) => getIt.get(param1: config);
  DeleteLocationCubit getDeleteLocationCubit(DeleteLocationConfig config) => getIt.get(param1: config);
  NavigationToAnotherOwnerCubit getNavigationToAnotherOwnerCubit(NavigationToAnotherOwnerConfig config) => getIt.get(param1: config);
  SwitchToBoardCubit getSwitchToBoardCubit(SwitchToBoardConfig config) => getIt.get(param1: config);
  LogoutFromAccountCubit getLogoutFromAccountCubit(LogoutFromAccountConfig config) => getIt.get(param1: config);

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

  SpecialistsCubit getSpecialistsCubit(SpecialistsConfig config) => getIt.get(param1: config);
  CreateSpecialistCubit getCreateSpecialistCubit(CreateSpecialistConfig config) => getIt.get(param1: config);
  DeleteSpecialistCubit getDeleteSpecialistCubit(DeleteSpecialistConfig config) => getIt.get(param1: config);

  ClientCubit getClientCubit(ClientConfig config) => getIt.get(param1: config);
  CreateClientCubit getAddClientCubit(CreateClientConfig config) => getIt.get(param1: config);

  BoardCubit getBoardCubit(BoardConfig config) => getIt.get(param1: config);

  RightsCubit getRightsCubit(RightsConfig config) => getIt.get(param1: config);
  AddRightsCubit getAddRightsCubit(AddRightsConfig config) => getIt.get(param1: config);
  DeleteRightsCubit getDeleteRightsCubit(DeleteRightsConfig config) => getIt.get(param1: config);

  SwitchToKioskCubit getSwitchToKioskCubit(SwitchToKioskConfig config) => getIt.get(param1: config);
}

const statesAssembler = StatesAssembler._();
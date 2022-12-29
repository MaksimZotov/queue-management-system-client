import 'package:queue_management_system_client/ui/screens/verification/authorization.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/screens/verification/select.dart';

import '../../ui/screens/verification/confirmation.dart';
import '../main/main.dart';

class StatesAssembler {
  const StatesAssembler._();

  SelectCubit getSelectCubit() => getIt.get();
  RegistrationCubit getRegistrationCubit() => getIt.get();
  ConfirmationCubit getConfirmationCubit(ConfirmationParams params) => getIt.get(param1: params);
  AuthorizationCubit getAuthorizationCubit() => getIt.get();
}

const statesAssembler = StatesAssembler._();
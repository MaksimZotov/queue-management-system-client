import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class LogoutFromAccountConfig extends BaseDialogConfig {}
class LogoutFromAccountResult extends BaseDialogResult {}

class LogoutFromAccountWidget extends BaseDialogWidget<LogoutFromAccountConfig> {

  const LogoutFromAccountWidget({
    super.key,
    required super.config
  });

  @override
  State<LogoutFromAccountWidget> createState() => _LogoutFromAccountState();
}

class _LogoutFromAccountState extends BaseDialogState<
    LogoutFromAccountWidget,
    LogoutFromAccountLogicState,
    LogoutFromAccountCubit
> {

  @override
  String getTitle(
      BuildContext context,
      LogoutFromAccountLogicState state,
      LogoutFromAccountWidget widget
  ) => getLocalizations(context).logoutFromAccountQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      LogoutFromAccountLogicState state,
      LogoutFromAccountWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).logout,
        onClick: getCubitInstance(context).logoutFromAccount
    )
  ];

  @override
  LogoutFromAccountCubit getCubit() =>
      statesAssembler.getLogoutFromAccountCubit(widget.config);
}

class LogoutFromAccountLogicState extends BaseDialogLogicState<
    LogoutFromAccountConfig,
    LogoutFromAccountResult
> {

  LogoutFromAccountLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    required super.config,
    super.result,
    super.loading,
  });

  @override
  LogoutFromAccountLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    LogoutFromAccountResult? result
  }) => LogoutFromAccountLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result
  );
}

@injectable
class LogoutFromAccountCubit extends BaseDialogCubit<LogoutFromAccountLogicState> {

  LogoutFromAccountCubit(
      @factoryParam LogoutFromAccountConfig config
  ) : super(
      LogoutFromAccountLogicState(
        config: config,
      )
  );

  void logoutFromAccount() {
    popResult(LogoutFromAccountResult());
  }
}
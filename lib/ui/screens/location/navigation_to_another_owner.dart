import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class NavigationToAnotherOwnerConfig extends BaseDialogConfig {}

class NavigationToAnotherOwnerResult extends BaseDialogResult {
  final String email;

  NavigationToAnotherOwnerResult({
    required this.email
  });
}

class NavigationToAnotherOwnerWidget extends BaseDialogWidget<NavigationToAnotherOwnerConfig> {

  const NavigationToAnotherOwnerWidget({
    super.key,
    required super.config
  });

  @override
  State<NavigationToAnotherOwnerWidget> createState() => _NavigationToAnotherOwnerState();
}

class _NavigationToAnotherOwnerState extends BaseDialogState<
    NavigationToAnotherOwnerWidget,
    NavigationToAnotherOwnerLogicState,
    NavigationToAnotherOwnerCubit
> {

  @override
  String getTitle(
      BuildContext context,
      NavigationToAnotherOwnerLogicState state,
      NavigationToAnotherOwnerWidget widget
  ) => getLocalizations(context).navigationToAnotherOwner;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      NavigationToAnotherOwnerLogicState state,
      NavigationToAnotherOwnerWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).emailOwner,
        text: state.email,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).navigate,
        onClick: getCubitInstance(context).findLocations
    )
  ];

  @override
  NavigationToAnotherOwnerCubit getCubit() =>
      statesAssembler.getNavigationToAnotherOwnerCubit(widget.config);
}

class NavigationToAnotherOwnerLogicState extends BaseDialogLogicState<
    NavigationToAnotherOwnerConfig,
    NavigationToAnotherOwnerResult
> {

  final String email;

  NavigationToAnotherOwnerLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email
  });

  @override
  NavigationToAnotherOwnerLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    NavigationToAnotherOwnerResult? result,
    String? email
  }) => NavigationToAnotherOwnerLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      email: email ?? this.email
  );
}

@injectable
class NavigationToAnotherOwnerCubit extends BaseDialogCubit<NavigationToAnotherOwnerLogicState> {

  NavigationToAnotherOwnerCubit(
      @factoryParam NavigationToAnotherOwnerConfig config
  ) : super(
      NavigationToAnotherOwnerLogicState(
          config: config,
          email: ''
      )
  );

  void setEmail(String text) {
    emit(state.copy(email: text));
  }

  void findLocations() {
    popResult(NavigationToAnotherOwnerResult(email: state.email));
  }
}
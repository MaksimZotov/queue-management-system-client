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
  final int accountId;

  NavigationToAnotherOwnerResult({
    required this.accountId
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
        label: getLocalizations(context).ownerIdentifier,
        text: state.accountId,
        onTextChanged: getCubitInstance(context).setAccountId,
        keyboardType: TextInputType.number,
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).navigate,
        onClick: () => getCubitInstance(context).findLocations(getLocalizations(context).identifierMustBeANumber)
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

  final String accountId;

  NavigationToAnotherOwnerLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.accountId
  });

  @override
  NavigationToAnotherOwnerLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    NavigationToAnotherOwnerResult? result,
    String? accountId
  }) => NavigationToAnotherOwnerLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      accountId: accountId ?? this.accountId
  );
}

@injectable
class NavigationToAnotherOwnerCubit extends BaseDialogCubit<NavigationToAnotherOwnerLogicState> {

  NavigationToAnotherOwnerCubit(
      @factoryParam NavigationToAnotherOwnerConfig config
  ) : super(
      NavigationToAnotherOwnerLogicState(
          config: config,
          accountId: ''
      )
  );

  void setAccountId(String text) {
    emit(state.copy(accountId: text));
  }

  void findLocations(String parseErrorMessage) {
    int? accountId = int.tryParse(state.accountId);
    if (accountId == null) {
      showSnackBar(parseErrorMessage);
    } else {
      popResult(NavigationToAnotherOwnerResult(accountId: int.parse(state.accountId)));
    }
  }
}
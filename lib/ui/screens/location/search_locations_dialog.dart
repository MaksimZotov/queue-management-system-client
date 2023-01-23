import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class SearchLocationsConfig extends BaseDialogConfig {}

class SearchLocationsResult extends BaseDialogResult {
  final String username;

  SearchLocationsResult({
    required this.username
  });
}

class SearchLocationsWidget extends BaseDialogWidget<SearchLocationsConfig> {

  const SearchLocationsWidget({
    super.key,
    required super.config
  });

  @override
  State<SearchLocationsWidget> createState() => _SearchLocationsState();
}

class _SearchLocationsState extends BaseDialogState<
    SearchLocationsWidget,
    SearchLocationsLogicState,
    SearchLocationsCubit
> {

  @override
  String getTitle(
      BuildContext context,
      SearchLocationsLogicState state,
      SearchLocationsWidget widget
  ) => getLocalizations(context).navigateToAnotherName;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      SearchLocationsLogicState state,
      SearchLocationsWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).uniqueName,
        text: state.username,
        onTextChanged: getCubitInstance(context).setUsername
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).navigate,
        onClick: getCubitInstance(context).findLocations
    )
  ];

  @override
  SearchLocationsCubit getCubit() =>
      statesAssembler.getSearchLocationsCubit(widget.config);
}

class SearchLocationsLogicState extends BaseDialogLogicState<
    SearchLocationsConfig,
    SearchLocationsResult
> {

  final String username;

  SearchLocationsLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.username
  });

  @override
  SearchLocationsLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    SearchLocationsResult? result,
    String? username
  }) => SearchLocationsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      username: username ?? this.username
  );
}

@injectable
class SearchLocationsCubit extends BaseDialogCubit<SearchLocationsLogicState> {

  SearchLocationsCubit(
      @factoryParam SearchLocationsConfig config
  ) : super(
      SearchLocationsLogicState(
          config: config,
          username: ''
      )
  );

  void setUsername(String text) {
    emit(state.copy(username: text));
  }

  void findLocations() {
    popResult(SearchLocationsResult(username: state.username));
  }
}
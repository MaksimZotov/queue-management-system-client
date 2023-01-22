import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';

import '../widgets/button_widget.dart';

abstract class BaseWidget extends StatefulWidget {
  final ValueChanged<BaseConfig> emitConfig;

  const BaseWidget({super.key, required this.emitConfig});
}

abstract class BaseState<
  W extends BaseWidget,
  S extends BaseLogicState,
  C extends BaseCubit<S>
> extends State<W> {

  @override
  Widget build(BuildContext context) => BlocProvider<C>(
    create: (context) => getCubit()..onStart(),
    child: BlocConsumer<C, S>(
      listener: (context, state) => handleEvent(context, state, widget),
      builder: (context, state) => getWidget(context, state, widget)
    ),
  );

  Widget getWidget(BuildContext context, S state, W widget);
  C getCubit();

  void handleEvent(BuildContext context, S state, W widget) {
    checkConfigEmit(state.nextConfig);
    checkSnackBar(context, state.snackBar);
    checkError(context, state.error);
  }

  void checkConfigEmit(BaseConfig? config) {
    if (config != null) {
      widget.emitConfig(config);
    }
  }

  void checkSnackBar(BuildContext context, String? snackBar) {
    if (snackBar != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackBar))
      );
    }
  }

  void checkError(BuildContext context, ErrorResult? error) {
    if (error != null) {
      String? message;
      switch (error.type) {
        case ErrorType.standard:
          message = error.description;
          break;
        case ErrorType.unknown:
          message = AppLocalizations.of(context)!.unknownError;
          break;
        case ErrorType.server:
          message = AppLocalizations.of(context)!.serverError;
          break;
        case ErrorType.timeout:
          message = AppLocalizations.of(context)!.timeoutError;
          break;
        case ErrorType.connection:
          message = AppLocalizations.of(context)!.connectionError;
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  message ?? AppLocalizations.of(context)!.unknownError
              )
          )
      );
    }
  }
}

abstract class BaseDialogState<
  W extends BaseWidget,
  S extends BaseLogicState,
  C extends BaseCubit<S>
> extends BaseState<W, S, C> {

  String getTitle(BuildContext context, S state, W widget);
  List<Widget> getDialogContentWidget(BuildContext context, S state, W widget);

  @override
  Widget getWidget(BuildContext context, S state, W widget) => SimpleDialog(
    title: Text(getTitle(context, state, widget)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(16.0)
        )
    ),
    children: getDialogContentWidget(context, state, widget) + [
      const SizedBox(height: 10),
      ButtonWidget(
          text: AppLocalizations.of(context)!.cancel,
          onClick: Navigator.of(context).pop
      )
    ],
  );
}

abstract class BaseLogicState {

  final BaseConfig? nextConfig;
  final ErrorResult? error;
  final String? snackBar;
  final bool loading;

  BaseLogicState({
    this.nextConfig,
    this.error,
    this.snackBar,
    this.loading = false
  });

  dynamic copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  });
}

class BaseCubit<T extends BaseLogicState> extends Cubit<T> {
  BaseCubit(super.initialState);

  Future<void> onStart() async {}

  void showSnackBar(String? message) {
    emit(state.copy(snackBar: message));
    emit(state.copy(snackBar: null));
  }

  void showError(ErrorResult result) {
    emit(state.copy(loading: false, error: result));
    emit(state.copy(error: null));
  }

  void showLoad() {
    emit((state).copy(loading: true));
  }

  void hideLoad() {
    emit(state.copy(loading: false));
  }

  void navigate(BaseConfig config) {
    emit(state.copy(nextConfig: config));
    emit(state.copy(nextConfig: null));
  }
}
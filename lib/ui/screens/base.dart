import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';

abstract class BaseWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;

  BaseWidget({super.key, required this.emitConfig});
}

abstract class BaseState<
  W extends BaseWidget,
  S extends BaseLogicState,
  C extends BaseCubit<S>
> extends State<W> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
      create: (context) => getCubit()..onStart(),
      child: BlocConsumer<C, S>(
        listener: (context, state) => handleEvent(context, state, widget),
        builder: (context, state) => getWidget(context, state, widget)
      ),
    );
  }

  C getCubit();

  Widget getWidget(BuildContext context, S state, W widget);

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
    emit(state.copy(snackBar: null));
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
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';

import '../../dimens.dart';
import '../widgets/button_widget.dart';

abstract class BaseWidget<T extends BaseConfig> extends StatefulWidget {
  final T config;
  final ValueChanged<BaseConfig> emitConfig;

  const BaseWidget({
    super.key,
    required this.config,
    required this.emitConfig
  });
}

abstract class BaseDialogWidget<
  T extends BaseDialogConfig
> extends StatefulWidget {
  final T config;

  const BaseDialogWidget({
    super.key,
    required this.config
  });
}

abstract class BaseState<
  W extends BaseWidget,
  S extends BaseLogicState,
  C extends BaseCubit<S>
> extends State<W> {

  AppLocalizations getLocalizations(BuildContext context) =>
      AppLocalizations.of(context)!;

  C getCubitInstance(BuildContext context) => BlocProvider.of<C>(context);

  @override
  Widget build(BuildContext context) => BlocProvider<C>(
    create: (context) => getCubit()..onStart(),
    child: BlocConsumer<C, S>(
      listener: (context, state) => handleEvent(context, state, widget),
      builder: (context, state) => getWidget(context, state, widget)
    ),
  );

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
      Flushbar(
          message: snackBar,
          duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  void checkError(BuildContext context, ErrorResult? error) {
    String? message = getErrorText(context, error);
    checkSnackBar(context, message);
  }

  String? getErrorText(BuildContext context, ErrorResult? error) {
    switch (error?.type) {
      case ErrorType.standard:
        return error?.description;
      case ErrorType.unknown:
        return getLocalizations(context).unknownError;
      case ErrorType.server:
        return getLocalizations(context).serverError;
      case ErrorType.timeout:
        return getLocalizations(context).timeoutError;
      case ErrorType.connection:
        return getLocalizations(context).connectionError;
      case null:
        return null;
    }
  }

  Widget getWidget(BuildContext context, S state, W widget);
  C getCubit();
}

abstract class BaseDialogState<
  W extends BaseDialogWidget,
  S extends BaseDialogLogicState,
  C extends BaseDialogCubit<S>
> extends State<W> {

  AppLocalizations getLocalizations(BuildContext context) =>
      AppLocalizations.of(context)!;

  C getCubitInstance(BuildContext context) => BlocProvider.of<C>(context);

  @override
  Widget build(BuildContext context) => BlocProvider<C>(
    create: (context) => getCubit()..onStart(),
    child: BlocConsumer<C, S>(
        listener: (context, state) => handleEvent(context, state, widget),
        builder: (context, state) => state.loading
            ? const Center(child: CircularProgressIndicator())
            : SimpleDialog(
              title: Text(getTitle(context, state, widget)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16
              ),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(16.0)
                  )
              ),
              children: getDialogContentWidget(context, state, widget) + [
                const SizedBox(height: Dimens.contentMargin),
                ButtonWidget(
                    text: getLocalizations(context).cancel,
                    onClick: Navigator.of(context).pop
                )
              ],
            )
    ),
  );

  void handleEvent(BuildContext context, S state, W widget) {
    checkSnackBar(context, state.snackBar);
    checkError(context, state.error);
    checkResult(context, state.result);
  }

  void checkSnackBar(BuildContext context, String? snackBar) {
    if (snackBar != null) {
      Flushbar(
        message: snackBar,
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  void checkResult(BuildContext context, BaseDialogResult? result) {
    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  void checkError(BuildContext context, ErrorResult? error) {
    String? message = getErrorText(context, error);
    checkSnackBar(context, message);
  }

  String? getErrorText(BuildContext context, ErrorResult? error) {
    switch (error?.type) {
      case ErrorType.standard:
        return error?.description;
      case ErrorType.unknown:
        return getLocalizations(context).unknownError;
      case ErrorType.server:
        return getLocalizations(context).serverError;
      case ErrorType.timeout:
        return getLocalizations(context).timeoutError;
      case ErrorType.connection:
        return getLocalizations(context).connectionError;
      case null:
        return null;
    }
  }

  String getTitle(BuildContext context, S state, W widget);
  List<Widget> getDialogContentWidget(BuildContext context, S state, W widget);
  C getCubit();
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

abstract class BaseDialogConfig {}
abstract class BaseDialogResult {}

abstract class BaseDialogLogicState<
    C extends BaseDialogConfig,
    R extends BaseDialogResult
> {
  final BaseConfig? nextConfig;
  final ErrorResult? error;
  final String? snackBar;
  final bool loading;
  final C config;
  final R? result;

  BaseDialogLogicState({
    this.nextConfig,
    this.error,
    this.snackBar,
    this.loading = false,
    required this.config,
    this.result
  });

  dynamic copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    R? result
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

class BaseDialogCubit<T extends BaseDialogLogicState> extends Cubit<T> {
  BaseDialogCubit(super.initialState);

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

  void popResult(BaseDialogResult result) {
    emit(state.copy(result: result));
  }
}
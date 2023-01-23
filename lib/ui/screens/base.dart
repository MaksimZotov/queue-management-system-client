import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';

import '../../dimens.dart';
import '../widgets/button_widget.dart';

abstract class BaseWidget extends StatefulWidget {
  final ValueChanged<BaseConfig> emitConfig;

  const BaseWidget({
    super.key, required this.emitConfig
  });
}

abstract class BaseDialogWidget<T extends BaseDialogConfig> extends BaseWidget {
  final T config;

  const BaseDialogWidget({
    super.key,
    required super.emitConfig,
    required this.config
  });
}

abstract class BaseState<
  W extends BaseWidget,
  S extends BaseLogicState,
  C extends BaseCubit<S>
> extends State<W> {

  AppLocalizations getLocalizations(BuildContext context) =>
      getLocalizations(context);

  C getCubitInstance(BuildContext context) => BlocProvider.of<C>(context);

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
      Flushbar(
          message: snackBar,
          icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
          ),
          duration: const Duration(seconds: 3),
      ).show(context);
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
          message = getLocalizations(context).unknownError;
          break;
        case ErrorType.server:
          message = getLocalizations(context).serverError;
          break;
        case ErrorType.timeout:
          message = getLocalizations(context).timeoutError;
          break;
        case ErrorType.connection:
          message = getLocalizations(context).connectionError;
          break;
      }
      if (message == null) {
        return;
      }
      checkSnackBar(context, message);
    }
  }
}

abstract class BaseDialogState<
  W extends BaseWidget,
  S extends BaseDialogLogicState,
  C extends BaseCubit<S>
> extends BaseState<W, S, C> {

  @override
  void handleEvent(BuildContext context, S state, W widget) {
    super.handleEvent(context, state, widget);
    if (state.result != null) {
      Navigator.of(context).pop(state.result);
    }
  }

  String getTitle(BuildContext context, S state, W widget);
  List<Widget> getDialogContentWidget(BuildContext context, S state, W widget);

  @override
  Widget getWidget(BuildContext context, S state, W widget) => state.loading
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

  dynamic copyBase({
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
> extends BaseLogicState {
  final C config;
  final R? result;

  BaseDialogLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    this.result
  });

  dynamic copyResult({
    R? result
  });
}

class BaseCubit<T extends BaseLogicState> extends Cubit<T> {
  BaseCubit(super.initialState);

  Future<void> onStart() async {}

  void showSnackBar(String? message) {
    emit(state.copyBase(snackBar: message));
    emit(state.copyBase(snackBar: null));
  }

  void showError(ErrorResult result) {
    emit(state.copyBase(loading: false, error: result));
    emit(state.copyBase(error: null));
  }

  void showLoad() {
    emit((state).copyBase(loading: true));
  }

  void hideLoad() {
    emit(state.copyBase(loading: false));
  }

  void navigate(BaseConfig config) {
    emit(state.copyBase(nextConfig: config));
    emit(state.copyBase(nextConfig: null));
  }
}

class BaseDialogCubit<T extends BaseDialogLogicState> extends BaseCubit<T> {

  BaseDialogCubit(super.initialState);

  void popResult(BaseDialogResult result) {
    emit(state.copyResult(result: result));
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (state.nextConfig != null) {
      widget.emitConfig(state.nextConfig!);
    }
    if (state.snackBar != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.snackBar!)
          )
      );
    }
  }
}

abstract class BaseLogicState {

  final BaseConfig? nextConfig;
  final String? snackBar;
  final bool loading;

  BaseLogicState({
    this.nextConfig,
    this.snackBar,
    this.loading = false
  });

  dynamic copy({
    BaseConfig? nextConfig,
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

  void showError(String? message) {
    emit(state.copy(loading: false, snackBar: message));
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
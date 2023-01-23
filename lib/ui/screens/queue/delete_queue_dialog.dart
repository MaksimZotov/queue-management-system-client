import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/queue_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteQueueConfig extends BaseDialogConfig {
  final int id;

  DeleteQueueConfig({
    required this.id,
  });
}

class DeleteQueueResult extends BaseDialogResult {
  final int id;

  DeleteQueueResult({
    required this.id,
  });
}

class DeleteQueueWidget extends BaseDialogWidget<DeleteQueueConfig> {

  const DeleteQueueWidget({
    super.key,
    required super.emitConfig,
    required super.config
  });

  @override
  State<DeleteQueueWidget> createState() => _DeleteQueueState();
}

class _DeleteQueueState extends BaseDialogState<
    DeleteQueueWidget,
    DeleteQueueLogicState,
    DeleteQueueCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteQueueLogicState state,
      DeleteQueueWidget widget
  ) => getLocalizations(context).deleteQueueQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteQueueLogicState state,
      DeleteQueueWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).delete,
        onClick: () => Navigator.of(context).pop(
            DeleteQueueResult(
                id: widget.config.id
            )
        )
    )
  ];

  @override
  DeleteQueueCubit getCubit() =>
      statesAssembler.getDeleteQueueCubit(widget.config);
}

class DeleteQueueLogicState extends BaseDialogLogicState<
    DeleteQueueConfig,
    DeleteQueueResult
> {

  DeleteQueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result
  });

  @override
  DeleteQueueLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => DeleteQueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
  );

  @override
  DeleteQueueLogicState copyResult({
    DeleteQueueResult? result
  }) => DeleteQueueLogicState(
    nextConfig: nextConfig,
    error: error,
    snackBar: snackBar,
    loading: loading,
    config: config,
    result: result,
  );
}

@injectable
class DeleteQueueCubit extends BaseDialogCubit<DeleteQueueLogicState> {

  final QueueInteractor _queueInteractor;

  DeleteQueueCubit(
      this._queueInteractor,
      @factoryParam DeleteQueueConfig config
  ) : super(
      DeleteQueueLogicState(
        config: config
      )
  );

  Future<void> deleteQueue(DeleteQueueResult result) async {
    showLoad();
    await _queueInteractor.deleteQueue(result.id)
      ..onSuccess((result) {
        popResult(DeleteQueueResult(id: state.config.id));
      })
      ..onError((result) {
        showError(result);
      });
  }
}
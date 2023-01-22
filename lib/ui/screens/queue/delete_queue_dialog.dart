import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteQueueConfig {
  final int id;

  DeleteQueueConfig({
    required this.id,
  });
}

class DeleteQueueResult {
  final int id;

  DeleteQueueResult({
    required this.id,
  });
}

class DeleteQueueWidget extends BaseWidget {
  final DeleteQueueConfig config;

  const DeleteQueueWidget({super.key, required super.emitConfig, required this.config});

  @override
  State<DeleteQueueWidget> createState() => _DeleteQueueState();
}

class _DeleteQueueState extends BaseDialogState<DeleteQueueWidget, DeleteQueueLogicState, DeleteQueueCubit> {

  @override
  String getTitle(
      BuildContext context,
      DeleteQueueLogicState state,
      DeleteQueueWidget widget
  ) => AppLocalizations.of(context)!.deleteQueueQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteQueueLogicState state,
      DeleteQueueWidget widget
  ) => [
    ButtonWidget(
        text: AppLocalizations.of(context)!.delete,
        onClick: () => Navigator.of(context).pop(
            DeleteQueueResult(
                id: widget.config.id
            )
        )
    )
  ];

  @override
  DeleteQueueCubit getCubit() => statesAssembler.getDeleteQueueCubit();
}

class DeleteQueueLogicState extends BaseLogicState {

  DeleteQueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading
  });

  @override
  DeleteQueueLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => DeleteQueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class DeleteQueueCubit extends BaseCubit<DeleteQueueLogicState> {
  DeleteQueueCubit() : super(DeleteQueueLogicState());
}
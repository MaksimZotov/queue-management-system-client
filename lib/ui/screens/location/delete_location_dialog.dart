import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class DeleteLocationConfig {
  final int id;

  DeleteLocationConfig({
    required this.id,
  });
}

class DeleteLocationResult {
  final int id;

  DeleteLocationResult({
    required this.id,
  });
}

class DeleteLocationWidget extends BaseWidget {
  final DeleteLocationConfig config;

  const DeleteLocationWidget({super.key, required super.emitConfig, required this.config});

  @override
  State<DeleteLocationWidget> createState() => _DeleteLocationState();
}

class _DeleteLocationState extends BaseDialogState<DeleteLocationWidget, DeleteLocationLogicState, DeleteLocationCubit> {

  @override
  String getTitle(
      BuildContext context,
      DeleteLocationLogicState state,
      DeleteLocationWidget widget
  ) => AppLocalizations.of(context)!.deleteLocationQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteLocationLogicState state,
      DeleteLocationWidget widget
  ) => [
    ButtonWidget(
        text: AppLocalizations.of(context)!.delete,
        onClick: () => Navigator.of(context).pop(
            DeleteLocationResult(
                id: widget.config.id
            )
        )
    )
  ];

  @override
  DeleteLocationCubit getCubit() => statesAssembler.getDeleteLocationCubit();
}

class DeleteLocationLogicState extends BaseLogicState {

  DeleteLocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading
  });

  @override
  DeleteLocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => DeleteLocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class DeleteLocationCubit extends BaseCubit<DeleteLocationLogicState> {
  DeleteLocationCubit() : super(DeleteLocationLogicState());
}
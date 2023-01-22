import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';


class ConfirmResult {
  final String code;

  ConfirmResult({
    required this.code
  });
}


class ConfirmWidget extends BaseWidget {

  const ConfirmWidget({super.key, required super.emitConfig});

  @override
  State<ConfirmWidget> createState() => _ConfirmState();
}

class _ConfirmState extends BaseDialogState<ConfirmWidget, ConfirmLogicState, ConfirmCubit> {

  @override
  String getTitle(
      BuildContext context,
      ConfirmLogicState state,
      ConfirmWidget widget
  ) => AppLocalizations.of(context)!.codeConfirmation;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ConfirmLogicState state,
      ConfirmWidget widget
  ) => [
    TextFieldWidget(
        label: AppLocalizations.of(context)!.code,
        text: state.code,
        onTextChanged: BlocProvider.of<ConfirmCubit>(context).setCode
    ),
    const SizedBox(height: 10),
    ButtonWidget(
        text: AppLocalizations.of(context)!.confirm,
        onClick: () => Navigator.of(context).pop(
            ConfirmResult(
                code: state.code
            )
        )
    )
  ];

  @override
  ConfirmCubit getCubit() => statesAssembler.getConfirmCubit();
}

class ConfirmLogicState extends BaseLogicState {

  final String code;

  ConfirmLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.code
  });

  ConfirmLogicState copyWith({
    String? code,
    String? description
  }) => ConfirmLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      code: code ?? this.code
  );

  @override
  ConfirmLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => ConfirmLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      code: code
  );
}

@injectable
class ConfirmCubit extends BaseCubit<ConfirmLogicState> {

  ConfirmCubit() : super(ConfirmLogicState(code: ''));

  void setCode(String text) {
    emit(state.copyWith(code: text));
  }
}
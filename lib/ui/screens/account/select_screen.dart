import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class SelectWidget extends BaseWidget {
  SelectWidget({super.key, required super.emitConfig});

  @override
  State<SelectWidget> createState() => SelectState();
}

class SelectState extends BaseState<SelectWidget, SelectLogicState, SelectCubit> {

  @override
  Widget getWidget(BuildContext context, SelectLogicState state, SelectWidget widget) => state.loading
      ? const Center(
        child: CircularProgressIndicator(),
      )
      : Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.enterAccount),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ButtonWidget(
                  text: AppLocalizations.of(context)!.authorization,
                  onClick: () {
                    widget.emitConfig(AuthorizationConfig());
                  },
                ),
                ButtonWidget(
                  text: AppLocalizations.of(context)!.registration,
                  onClick: () {
                    widget.emitConfig(RegistrationConfig());
                  },
                ),
              ],
            ),
          ),
        ),
  );

  @override
  SelectCubit getCubit() => statesAssembler.getSelectCubit();
}

enum SelectStateEnum {
  loading, stay, goToLocations
}

class SelectLogicState extends BaseLogicState {

  SelectLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
  });

  @override
  SelectLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => SelectLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class SelectCubit extends BaseCubit<SelectLogicState> {
  final LocationInteractor locationInteractor;
  final AccountInteractor accountInteractor;

  SelectCubit(
     this.locationInteractor,
     this.accountInteractor,
  ) : super(SelectLogicState());

  Future<void> onStart() async {
    if (await accountInteractor.checkToken()) {
      await locationInteractor.getLocations(null)
          ..onSuccess((value) async {
            String? username = await accountInteractor.getCurrentUsername();
            if (username != null) {
              navigate(LocationsConfig(username: username));
            }
          });
    }
    hideLoad();
  }
}

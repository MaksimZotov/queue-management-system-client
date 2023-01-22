import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/rights/add_rule_dialog.dart';
import 'package:queue_management_system_client/ui/screens/rights/delete_rule_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/rights_item_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/rights_interactor.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/base/result.dart';

class RightsWidget extends BaseWidget {
  final RightsConfig config;

  RightsWidget({super.key, required super.emitConfig, required this.config});

  @override
  State<RightsWidget> createState() => _RightsState();
}

class _RightsState extends BaseState<RightsWidget, RightsLogicState, RightsCubit> {

  @override
  Widget getWidget(BuildContext context, RightsLogicState state, RightsWidget widget) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.rightsSettings),
    ),
    body: ListView.builder(
      itemBuilder: (context, index) => RightsItemWidget(
        rights: state.rights[index],
        onDelete: (rights) => showDialog(
            context: context,
            builder: (context) => DeleteRuleWidget(
                config: DeleteRuleConfig(
                    email: rights.email
                )
            )
        ).then((result) {
          if (result is DeleteRuleResult) {
            BlocProvider.of<RightsCubit>(context).deleteRule(result);
          }
        }),
      ),
      itemCount: state.rights.length,
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => showDialog(
          context: context,
          builder: (context) => AddRuleWidget(emitConfig: widget.emitConfig)
      ).then((result) {
        if (result is AddRuleResult) {
          BlocProvider.of<RightsCubit>(context).addRule(result);
        }
      }),
      child: const Icon(Icons.add),
    ),
  );

  @override
  RightsCubit getCubit() => statesAssembler.getRightsCubit(widget.config);
}

class RightsLogicState extends BaseLogicState {

  static const int pageSize = 30;

  final RightsConfig config;
  final List<RightsModel> rights;
  final bool hasToken;

  RightsLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.rights,
    required this.hasToken
  });

  RightsLogicState copyWith({
    List<RightsModel>? rights,
    bool? hasToken
  }) => RightsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      rights: rights ?? this.rights,
      hasToken: hasToken ?? this.hasToken
  );

  @override
  RightsLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => RightsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      rights: rights,
      hasToken: hasToken
  );
}

@injectable
class RightsCubit extends BaseCubit<RightsLogicState> {

  final AccountInteractor accountInteractor;
  final RightsInteractor rightsInteractor;

  RightsCubit(
    this.rightsInteractor,
    this.accountInteractor,
    @factoryParam RightsConfig config
  ) : super(
    RightsLogicState(
      config: config,
      rights: [],
      hasToken: false
    )
  );

  @override
  Future<void> onStart() async {
    _reload();
  }

  Future addRule(AddRuleResult addRuleResult) async {
    showLoad();
    await rightsInteractor.addRights(state.config.locationId, addRuleResult.email)
      ..onSuccess((result) {
        _reload();
      })..onError((result) {
        showError(result);
      });
  }

  Future deleteRule(DeleteRuleResult deleteRuleResult) async {
    showLoad();
    await rightsInteractor.deleteRights(state.config.locationId, deleteRuleResult.email)
      ..onSuccess((result) {
        _reload();
      })..onError((result) {
        showError(result);
      });
  }

  Future _reload() async {
    await rightsInteractor.getRights(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(state.copyWith(rights: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/add_rule_dialog.dart';
import 'package:queue_management_system_client/ui/screens/rights/delete_rule_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/location_item_widget.dart';
import 'package:queue_management_system_client/ui/widgets/rights_item_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/rights_interactor.dart';
import '../../../domain/interactors/account_interactor.dart';

class RightsWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;
  final RightsConfig config;

  RightsWidget({super.key, required this.config, required this.emitConfig});

  @override
  State<RightsWidget> createState() => _RightsState();
}

class _RightsState extends State<RightsWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RightsCubit>(
      create: (context) => statesAssembler.getRightsCubit(widget.config)..onStart(),
      child: BlocConsumer<RightsCubit, RightsLogicState>(

        listener: (context, state) {
           if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.rightsSettings),
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              return RightsItemWidget(
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
              );
            },
            itemCount: state.rights.length,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => const AddRuleWidget()
            ).then((result) {
              if (result is AddRuleResult) {
                BlocProvider.of<RightsCubit>(context).addRule(result);
              }
            }),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class RightsLogicState {

  static const int pageSize = 30;

  final RightsConfig config;

  final List<RightsModel> rights;

  final bool hasToken;
  
  final String? snackBar;
  final bool loading;


  RightsLogicState({
    required this.config,
    required this.rights,
    required this.hasToken,
    required this.snackBar,
    required this.loading,
  });

  RightsLogicState copyWith({
    List<RightsModel>? rights,
    bool? hasToken,
    String? snackBar,
    bool? loading,
  }) => RightsLogicState(
      config: config,
      rights: rights ?? this.rights,
      hasToken: hasToken ?? this.hasToken,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class RightsCubit extends Cubit<RightsLogicState> {

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
      hasToken: false,
      snackBar: null,
      loading: false
    )
  );

  Future<void> onStart() async {
    _reload();
  }

  Future addRule(AddRuleResult addRuleResult) async {
    emit(state.copyWith(loading: true));
    await rightsInteractor.addRights(state.config.locationId, addRuleResult.email)
      ..onSuccess((result) {
        _reload();
      })..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future deleteRule(DeleteRuleResult deleteRuleResult) async {
    emit(state.copyWith(loading: true));
    await rightsInteractor.deleteRights(state.config.locationId, deleteRuleResult.email)
      ..onSuccess((result) {
        _reload();
      })..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future _reload() async {
    await rightsInteractor.getRights(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(
            state.copyWith(
                rights: result.data.results
            )
        );
      })
      ..onError((result) {
        emit(state.copyWith(snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }
}
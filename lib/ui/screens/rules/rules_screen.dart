import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/rules/rules_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/screens/rules/add_rule_dialog.dart';
import 'package:queue_management_system_client/ui/screens/rules/delete_rule_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/location_item_widget.dart';
import 'package:queue_management_system_client/ui/widgets/rules_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/rules_interactor.dart';
import '../../../domain/interactors/verification_interactor.dart';
import '../../../domain/models/base/container_for_list.dart';
import '../../../domain/models/base/result.dart';

class RulesWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;
  final RulesConfig config;

  RulesWidget({super.key, required this.config, required this.emitConfig});

  @override
  State<RulesWidget> createState() => _RulesState();
}

class _RulesState extends State<RulesWidget> {
  final String title = 'Настройки доступа';
  final String createLocationHint = 'Создать локацию';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RulesCubit>(
      create: (context) => statesAssembler.getRulesCubit(widget.config)..onStart(),
      child: BlocConsumer<RulesCubit, RulesLogicState>(

        listener: (context, state) {
           if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              return RulesItemWidget(
                rules: state.rules[index],
                onDelete: (rules) => showDialog(
                    context: context,
                    builder: (context) => DeleteRuleWidget(
                        config: DeleteRuleConfig(
                            email: rules.email
                        )
                    )
                ).then((result) {
                  if (result is DeleteRuleResult) {
                    BlocProvider.of<RulesCubit>(context).deleteRule(result);
                  }
                }),
              );
            },
            itemCount: state.rules.length,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => const AddRuleWidget()
            ).then((result) {
              if (result is AddRuleResult) {
                BlocProvider.of<RulesCubit>(context).addRule(result);
              }
            }),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class RulesLogicState {

  static const int pageSize = 30;

  final RulesConfig config;

  final List<RulesModel> rules;

  final bool hasToken;
  
  final String? snackBar;
  final bool loading;


  RulesLogicState({
    required this.config,
    required this.rules,
    required this.hasToken,
    required this.snackBar,
    required this.loading,
  });

  RulesLogicState copyWith({
    List<RulesModel>? rules,
    bool? hasToken,
    String? snackBar,
    bool? loading,
  }) => RulesLogicState(
      config: config,
      rules: rules ?? this.rules,
      hasToken: hasToken ?? this.hasToken,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class RulesCubit extends Cubit<RulesLogicState> {

  final VerificationInteractor verificationInteractor;
  final RulesInteractor rulesInteractor;

  RulesCubit(
    this.rulesInteractor,
    this.verificationInteractor,
    @factoryParam RulesConfig config
  ) : super(
    RulesLogicState(
      config: config,
      rules: [],
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
    await rulesInteractor.addRules(state.config.locationId, addRuleResult.email)
      ..onSuccess((result) {
        _reload();
      })..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future deleteRule(DeleteRuleResult deleteRuleResult) async {
    emit(state.copyWith(loading: true));
    await rulesInteractor.deleteRules(state.config.locationId, deleteRuleResult.email)
      ..onSuccess((result) {
        _reload();
      })..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future _reload() async {
    await rulesInteractor.getRules(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(
            state.copyWith(
                rules: result.data.results
            )
        );
      })
      ..onError((result) {
        emit(state.copyWith(snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }
}
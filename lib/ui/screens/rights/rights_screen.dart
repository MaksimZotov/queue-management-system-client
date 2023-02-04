import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/rights/add_rights_dialog.dart';
import 'package:queue_management_system_client/ui/screens/rights/delete_rights_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/rights_item_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/rights_interactor.dart';
import '../../../domain/models/base/result.dart';

class RightsWidget extends BaseWidget<RightsConfig> {
  
  const RightsWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<RightsWidget> createState() => _RightsState();
}

class _RightsState extends BaseState<
    RightsWidget, RightsLogicState, RightsCubit> {

  @override
  Widget getWidget(
      BuildContext context,
      RightsLogicState state,
      RightsWidget widget
  ) => Scaffold(
    appBar: AppBar(
      title: Text(getLocalizations(context).rightsSettings),
    ),
    body: ListView.builder(
      itemBuilder: (context, index) => RightsItemWidget(
        rights: state.rights[index],
        onDelete: (rights) => showDialog(
            context: context,
            builder: (context) => DeleteRightsWidget(
                config: DeleteRightsConfig(
                    locationId: state.config.locationId,
                    email: rights.email
                )
            )
        ).then((result) {
          if (result is DeleteRightsResult) {
            getCubitInstance(context).handleDeleteResult(result);
          }
        }),
      ),
      itemCount: state.rights.length,
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => showDialog(
          context: context,
          builder: (context) => AddRightsWidget(
              config: AddRightsConfig(
                locationId: state.config.locationId
              )
          )
      ).then((result) {
        if (result is AddRightsResult) {
          getCubitInstance(context).handleAddResult(result);
        }
      }),
      child: const Icon(Icons.add),
    ),
  );

  @override
  RightsCubit getCubit() => statesAssembler.getRightsCubit(widget.config);
}

class RightsLogicState extends BaseLogicState {

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

  @override
  RightsLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    List<RightsModel>? rights,
    bool? hasToken
  }) => RightsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      rights: rights ?? this.rights,
      hasToken: hasToken ?? this.hasToken
  );
}

@injectable
class RightsCubit extends BaseCubit<RightsLogicState> {

  final RightsInteractor _rightsInteractor;

  RightsCubit(
    this._rightsInteractor,
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
    _load();
  }

  void handleAddResult(AddRightsResult result) {
    emit(
        state.copy(
            rights: state.rights + [
              RightsModel(
                  locationId: state.config.locationId,
                  email: result.email
              )
            ]
        )
    );
  }

  void handleDeleteResult(DeleteRightsResult result) {
    emit(
        state.copy(
            rights: state.rights
              ..removeWhere((element) => element.email == result.email)
        )
    );
  }

  Future<void> _load() async {
    await _rightsInteractor.getRights(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(state.copy(rights: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}
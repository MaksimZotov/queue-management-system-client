import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/location_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/account_interactor.dart';

class LocationsWidget extends BaseWidget<LocationsConfig> {

  const LocationsWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<LocationsWidget> createState() => _LocationsState();
}

class _LocationsState extends BaseState<
    LocationsWidget,
    LocationsLogicState,
    LocationsCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      LocationsLogicState state,
      LocationsWidget widget
  ) => Scaffold(
    appBar: AppBar(
      title: Text(getLocalizations(context).locations),
      actions: <Widget>[
        IconButton(
          icon: Icon(state.hasToken ? Icons.logout : Icons.login),
          onPressed: getCubitInstance(context).logout,
        )
      ],
    ),
    body: ListView.builder(
      itemBuilder: (context, index) => LocationItemWidget(
        location: state.locations[index],
        onClick: (location) => widget.emitConfig(
            QueuesConfig(
                username: state.config.username,
                locationId: location.id!
            )
        ),
        onDelete: (location) => showDialog(
            context: context,
            builder: (context) => DeleteLocationWidget(
                config: DeleteLocationConfig(id: location.id!)
            )
        ).then((result) {
          if (result is DeleteLocationResult) {
            getCubitInstance(context).handleDeleteLocationResult(result);
          }
        }),
      ),
      itemCount: state.locations.length,
    ),
    floatingActionButton: state.hasRights
        ? FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => CreateLocationWidget(
                  config: CreateLocationConfig()
              )
          ).then((result) {
            if (result is CreateLocationResult) {
              getCubitInstance(context).handleCreateLocationResult(result);
            }
          }),
          child: const Icon(Icons.add),
        )
        : null,
  );

  @override
  LocationsCubit getCubit() => statesAssembler.getLocationsCubit(widget.config);
}

class LocationsLogicState extends BaseLogicState {

  final LocationsConfig config;

  final List<LocationModel> locations;

  final bool hasRights;
  final bool hasToken;

  LocationsLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.locations,
    required this.hasRights,
    required this.hasToken,
  });

  LocationsLogicState copyWith({
    List<LocationModel>? locations,
    bool? hasRights,
    bool? hasToken,
  }) => LocationsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      locations: locations ?? this.locations,
      hasRights: hasRights ?? this.hasRights,
      hasToken: hasToken ?? this.hasToken
  );

  @override
  LocationsLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => LocationsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      locations: locations,
      hasRights: hasRights,
      hasToken: hasToken
  );
}

@injectable
class LocationsCubit extends BaseCubit<LocationsLogicState> {

  final LocationInteractor _locationInteractor;
  final AccountInteractor _accountInteractor;

  LocationsCubit(
    this._locationInteractor,
    this._accountInteractor,
    @factoryParam LocationsConfig config
  ) : super(
    LocationsLogicState(
      config: config,
      locations: [],
      hasRights: false,
      hasToken: false,
      snackBar: null,
      loading: false
    )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    if (await _accountInteractor.checkToken()) {
      emit(state.copyWith(hasToken: true));
    }
    await _locationInteractor.checkHasRights(state.config.username)
      ..onSuccess((result) async {
        emit(state.copyWith(hasRights: result.data.hasRights));
      })
      ..onError((result) {
        showError(result);
      });
    await _load();
  }

  Future<void> logout() async {
    await _accountInteractor.logout();
    navigate(InitialConfig());
  }

  Future<void> handleCreateLocationResult(CreateLocationResult result) async {
    emit(state.copyWith(locations: state.locations + [result.locationModel]));
  }

  Future handleDeleteLocationResult(DeleteLocationResult result) async {
    emit(
        state.copyWith(
            locations: state.locations
              ..removeWhere((element) => element.id == result.id)
        )
    );
  }

  Future _load() async {
    await _locationInteractor.getLocations(state.config.username)
      ..onSuccess((result) {
        emit(state.copyWith(locations: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}
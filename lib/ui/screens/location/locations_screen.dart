import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/navigation_to_another_owner.dart';
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
          tooltip: getLocalizations(context).shareOwnerIdentifier,
          icon: const Icon(Icons.share),
          onPressed: () => getCubitInstance(context).share(
              getLocalizations(context).ownerIdentifierCopied
          ),
        ),
        IconButton(
          tooltip: getLocalizations(context).navigateToAnotherOwner,
          icon: const Icon(Icons.move_up),
          onPressed: () => showDialog(
              context: context,
              builder: (context) => NavigationToAnotherOwnerWidget(
                  config: NavigationToAnotherOwnerConfig()
              )
          ).then((result) {
            if (result is NavigationToAnotherOwnerResult) {
              widget.emitConfig(LocationsConfig(accountId: result.accountId));
            }
          }),
        ),
        IconButton(
          tooltip: state.hasToken ? getLocalizations(context).logout : getLocalizations(context).login,
          icon: Icon(state.hasToken ? Icons.logout : Icons.login),
          onPressed: getCubitInstance(context).logout,
        )
      ],
    ),
    body: ListView.builder(
      itemBuilder: (context, index) => LocationItemWidget(
        location: state.locations[index],
        onClick: (location) => widget.emitConfig(
            LocationConfig(
                accountId: state.config.accountId,
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
    floatingActionButton: state.isOwner
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

  final bool isOwner;
  final bool hasToken;

  LocationsLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.locations,
    required this.isOwner,
    required this.hasToken,
  });

  @override
  LocationsLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    List<LocationModel>? locations,
    bool? isOwner,
    bool? hasToken
  }) => LocationsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      locations: locations ?? this.locations,
      isOwner: isOwner ?? this.isOwner,
      hasToken: hasToken ?? this.hasToken
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
      isOwner: false,
      hasToken: false,
      snackBar: null,
      loading: false
    )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    if (await _accountInteractor.checkToken()) {
      emit(state.copy(hasToken: true));
    }
    await _locationInteractor.checkIsOwner(state.config.accountId)
      ..onSuccess((result) async {
        emit(state.copy(isOwner: result.data.isOwner));
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
    emit(state.copy(locations: state.locations + [result.locationModel]));
  }

  Future handleDeleteLocationResult(DeleteLocationResult result) async {
    emit(
        state.copy(
            locations: state.locations
              ..removeWhere((element) => element.id == result.id)
        )
    );
  }

  Future<void> share(String notificationText) async {
    await Clipboard.setData(ClipboardData(text: state.config.accountId.toString()));
    showSnackBar(notificationText);
  }

  Future _load() async {
    await _locationInteractor.getLocations(state.config.accountId)
      ..onSuccess((result) {
        emit(state.copy(locations: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}
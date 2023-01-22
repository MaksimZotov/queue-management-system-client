import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

class LocationsWidget extends BaseWidget {
  final LocationsConfig config;

  LocationsWidget({super.key, required super.emitConfig, required this.config});

  @override
  State<LocationsWidget> createState() => _LocationsState();
}

class _LocationsState extends BaseState<LocationsWidget, LocationsLogicState, LocationsCubit> {

  @override
  Widget getWidget(BuildContext context, LocationsLogicState state, LocationsWidget widget) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.locations),
      actions: <Widget>[
        IconButton(
          icon: Icon(state.hasToken ? Icons.logout : Icons.login),
          onPressed: BlocProvider.of<LocationsCubit>(context).logout,
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
                config: DeleteLocationConfig(
                    id: location.id!
                )
            )
        ).then((result) {
          if (result is DeleteLocationResult) {
            BlocProvider.of<LocationsCubit>(context).deleteLocation(result);
          }
        }),
      ),
      itemCount: state.locations.length,
    ),
    floatingActionButton: state.hasRights
        ? FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => const CreateLocationWidget()
          ).then((result) {
            if (result is CreateLocationResult) {
              BlocProvider.of<LocationsCubit>(context).createLocation(result);
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

  static const int pageSize = 30;

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
  LocationsLogicState copy({
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

  final LocationInteractor locationInteractor;
  final AccountInteractor accountInteractor;

  LocationsCubit(
    this.locationInteractor,
    this.accountInteractor,
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
    if (await accountInteractor.checkToken()) {
      emit(state.copyWith(hasToken: true));
    }
    await locationInteractor.checkHasRights(state.config.username)
      ..onSuccess((result) async {
        emit(state.copyWith(hasRights: result.data.hasRights));
      })
      ..onError((result) {
        showError(result);
      });
    await _reload();
  }

  Future<void> logout() async {
    await accountInteractor.logout();
    navigate(InitialConfig());
  }

  Future createLocation(CreateLocationResult result) async {
    showLoad();
    await locationInteractor.createLocation(
        LocationModel(
            id: null,
            name: result.name,
            description: result.description
        )
    )..onSuccess((result) {
      _reload();
    })..onError((result) {
      showError(result);
    });
  }

  Future deleteLocation(DeleteLocationResult result) async {
    showLoad();
    await locationInteractor.deleteLocation(result.id)..onSuccess((result) {
      _reload();
    })..onError((result) {
      showError(result);
    });
  }

  Future _reload() async {
    await locationInteractor.getLocations(state.config.username)
      ..onSuccess((result) {
        emit(state.copyWith(locations: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}
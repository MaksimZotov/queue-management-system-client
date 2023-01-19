import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location_dialog.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/widgets/location_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/base/container_for_list.dart';
import '../../../domain/models/base/result.dart';

class LocationsWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;
  final LocationsConfig config;

  LocationsWidget({super.key, required this.config, required this.emitConfig});

  @override
  State<LocationsWidget> createState() => _LocationsState();
}

class _LocationsState extends State<LocationsWidget> {
  final String title = 'Локации';
  final String createLocationHint = 'Создать локацию';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsCubit>(
      create: (context) => statesAssembler.getLocationsCubit(widget.config)..onStart(),
      child: BlocConsumer<LocationsCubit, LocationsLogicState>(

        listener: (context, state) {
          if (state.readyToLogout) {
            widget.emitConfig(InitialConfig());
          } else if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              IconButton(
                icon: Icon(state.hasToken ? Icons.logout : Icons.login),
                onPressed: BlocProvider.of<LocationsCubit>(context).logout,
              )
            ],
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              return LocationItemWidget(
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
              );
            },
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
            ) : null,
        ),
      ),
    );
  }
}

class LocationsLogicState {

  static const int pageSize = 30;

  final LocationsConfig config;

  final List<LocationModel> locations;

  final bool hasRights;
  final bool hasToken;

  final bool readyToLogout;
  
  final String? snackBar;
  final bool loading;


  LocationsLogicState({
    required this.config,
    required this.locations,
    required this.hasRights,
    required this.hasToken,
    required this.readyToLogout,
    required this.snackBar,
    required this.loading,
  });

  LocationsLogicState copyWith({
    List<LocationModel>? locations,
    bool? hasRights,
    bool? hasToken,
    bool? readyToLogout,
    String? snackBar,
    bool? loading,
  }) => LocationsLogicState(
      config: config,
      locations: locations ?? this.locations,
      hasRights: hasRights ?? this.hasRights,
      hasToken: hasToken ?? this.hasToken,
      readyToLogout: readyToLogout ?? this.readyToLogout,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class LocationsCubit extends Cubit<LocationsLogicState> {

  final LocationInteractor locationInteractor;
  final AccountInteractor accountInteractor;

  LocationsCubit({
    required this.locationInteractor,
    required this.accountInteractor,
    @factoryParam required LocationsConfig config
  }) : super(
    LocationsLogicState(
      config: config,
      locations: [],
      hasRights: false,
      hasToken: false,
      readyToLogout: false,
      snackBar: null,
      loading: false
    )
  );

  Future<void> onStart() async {
    emit(state.copyWith(loading: true));
    if (await accountInteractor.checkToken()) {
      emit(state.copyWith(hasToken: true));
    }
    await locationInteractor.checkHasRights(state.config.username)
      ..onSuccess((result) async {
        emit(state.copyWith(hasRights: result.data.hasRights));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
    await _reload();
  }

  Future<void> logout() async {
    await accountInteractor.logout();
    emit(state.copyWith(readyToLogout: true));
    emit(state.copyWith(readyToLogout: false));
  }

  Future createLocation(CreateLocationResult result) async {
    emit(state.copyWith(loading: true));
    await locationInteractor.createLocation(
        LocationModel(
            id: null,
            name: result.name,
            description: result.description
        )
    )..onSuccess((result) {
      _reload();
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
      emit(state.copyWith(snackBar: null));
    });
  }

  Future deleteLocation(DeleteLocationResult result) async {
    emit(state.copyWith(loading: true));
    await locationInteractor.deleteLocation(result.id)..onSuccess((result) {
      _reload();
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
      emit(state.copyWith(snackBar: null));
    });
  }

  Future _reload() async {
    await locationInteractor.getLocations(state.config.username)
      ..onSuccess((result) {
        emit(state.copyWith(loading: false, locations: result.data.results));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }
}
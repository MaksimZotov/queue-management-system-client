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

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsCubit>(
      create: (context) => statesAssembler.getLocationsCubit(widget.config)..onStart(),
      lazy: true,
      child: BlocBuilder<LocationsCubit, LocationsLogicState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: ListView.builder(
            controller: _scrollController
              ..addListener(() {
                if (_scrollController.offset ==
                    _scrollController.position.maxScrollExtent
                ) {
                  BlocProvider.of<LocationsCubit>(context).loadNext();
                }
              }),
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
          floatingActionButton: state.hasRules
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
  final int curPage;
  final bool isLast;

  // TODO - Сделать инициализацию поля через систему ролей
  final bool hasRules;
  
  final String? snackBar;
  final bool loading;


  LocationsLogicState({
    required this.config,
    required this.locations,
    required this.curPage,
    required this.isLast,
    required this.hasRules,
    required this.snackBar,
    required this.loading,
  });

  LocationsLogicState copyWith({
    List<LocationModel>? locations,
    int? curPage,
    bool? isLast,
    bool? hasRules,
    String? snackBar,
    bool? loading,
  }) => LocationsLogicState(
      config: config,
      locations: locations ?? this.locations,
      curPage: curPage ?? this.curPage,
      isLast: isLast ?? this.isLast,
      hasRules: hasRules ?? this.hasRules,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class LocationsCubit extends Cubit<LocationsLogicState> {

  final LocationInteractor locationInteractor;

  LocationsCubit({
    required this.locationInteractor,
    @factoryParam required LocationsConfig config
  }) : super(
    LocationsLogicState(
      config: config,
      locations: [],
      curPage: 0,
      isLast: false,
      hasRules: true,
      snackBar: null,
      loading: false
    )
  );

  Future<void> onStart() async {
    await loadNext();
  }

  Future<void> loadNext() async {
    if (state.loading || state.isLast) {
      return;
    }
    emit(state.copyWith(loading: true));
    await locationInteractor.getLocations(
        state.curPage,
        LocationsLogicState.pageSize,
        state.config.username
    )
      ..onSuccess((result) {
        emit(
            state.copyWith(
                loading: false,
                locations: state.locations + result.data.results,
                curPage: state.curPage + 1,
                isLast: result.data.isLast
            )
        );
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
      });
  }

  Future<void> createLocation(CreateLocationResult result) async {
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
    });
  }

  Future deleteLocation(DeleteLocationResult result) async {
    emit(state.copyWith(loading: true));
    await locationInteractor.deleteLocation(result.id)..onSuccess((result) {
      _reload();
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    });
  }

  Future<void> _reload() async {
    emit(state.copyWith(
      loading: false,
      locations: [],
      curPage: 0,
      isLast: false
    ));
    loadNext();
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}
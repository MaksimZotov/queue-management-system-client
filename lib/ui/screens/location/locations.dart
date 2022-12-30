import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/location_item.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/container_for_list.dart';
import '../../../domain/models/base/result.dart';
import '../../navigation/route_generator.dart';

class LocationsParams {
  final String? username;

  LocationsParams({
    this.username,
  });
}

class LocationsWidget extends StatefulWidget {
  final LocationsParams params;

  const LocationsWidget({super.key, required this.params});

  @override
  State<LocationsWidget> createState() => _LocationsState();
}

class _LocationsState extends State<LocationsWidget> {
  final String title = 'Локации';
  final String createLocationHint = 'Создать локацию';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsCubit>(
      create: (context) => statesAssembler.getLocationsCubit(widget.params)..onStart(),
      lazy: true,
      child: BlocConsumer<LocationsCubit, LocationsLogicState>(

        listener: (context, state) {
          if (state.readyToGoToLocation != null) {
            Navigator.of(context).pushNamed(Routes.toLocations).then((value) =>
                BlocProvider.of<LocationsCubit>(context).onPush()
            );
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: state.loading ? const Center(
            child: CircularProgressIndicator(),
          ) : state.readyToGoToLocation != null ? const SizedBox.shrink() : ListView.builder(
            itemBuilder: (context, index) {
              return LocationItemWidget(
                  location: state.locations[index],
                  onDelete: (location) => showDialog(
                      context: context,
                      builder: (context) => DeleteLocationWidget(
                          params: DeleteLocationParams(
                            id: location.id!
                          )
                      )
                  ),
              );
            },
            itemCount: state.locations.length,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => const CreateLocationWidget()
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class LocationsLogicState {

  static const int pageSize = 20;

  final LocationsParams params;

  final List<LocationModel> locations;
  final int curPage;
  final bool isLast;

  final int? readyToGoToLocation;
  
  final String? snackBar;
  final bool loading;


  LocationsLogicState({
    required this.params,
    required this.locations,
    required this.curPage,
    required this.isLast,
    required this.readyToGoToLocation,
    required this.snackBar,
    required this.loading,
  });

  LocationsLogicState copyWith({
    List<LocationModel>? locations,
    int? curPage,
    bool? isLast,
    int? readyToGoToLocation,
    String? snackBar,
    bool? loading,
  }) => LocationsLogicState(
      params: params,
      locations: locations ?? this.locations,
      curPage: curPage ?? this.curPage,
      isLast: isLast ?? this.isLast,
      readyToGoToLocation: readyToGoToLocation,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class LocationsCubit extends Cubit<LocationsLogicState> {

  final LocationInteractor locationInteractor;

  LocationsCubit({
    required this.locationInteractor,
    @factoryParam required LocationsParams params
  }) : super(
    LocationsLogicState(
      params: params,
      locations: [],
      curPage: 0,
      isLast: false,
      readyToGoToLocation: null,
      snackBar: null,
      loading: true
    )
  );

  Future<void> onStart() async {
    Result result;
    if (state.params.username == null) {
      result = await locationInteractor.getMyLocations(
          state.curPage,
          LocationsLogicState.pageSize
      );
    } else {
      // TODO
      result = await locationInteractor.getMyLocations(
          state.curPage,
          LocationsLogicState.pageSize
      );
    }
    if (result is SuccessResult<ContainerForList<LocationModel>>) {
      emit(
          state.copyWith(
            loading: false,
            locations: state.locations + result.data.results,
            curPage: state.curPage + 1,
            isLast: result.data.isLast
          )
      );
    } else if (result is ErrorResult) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    }
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }

  void onPush() {
    emit(state.copyWith(readyToGoToLocation: null));
  }
}
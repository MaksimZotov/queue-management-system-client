import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/container_for_list.dart';
import '../../../domain/models/base/result.dart';
import '../../navigation/route_generator.dart';

class LocationsWidget extends StatefulWidget {
  const LocationsWidget({super.key});

  @override
  State<LocationsWidget> createState() => _LocationsState();
}

class _LocationsState extends State<LocationsWidget> {
  final String title = 'Профиль';
  final String firstName = 'Иван';
  final String lastName = 'Иванов';
  final String email = 'email@gmail.com';
  final String share = 'Поделиться';
  final String rooms = 'Комнаты';
  final String my = 'Мои';
  final String other = 'Других';

  List<String> roomsList = [
    'Room1', 'Room2', 'Room3', 'Room4', 'Room5', 'Room6', 'Room7', 'Room8', 'Room9', 'Room10',
    'Room1', 'Room2', 'Room3', 'Room4', 'Room5', 'Room6', 'Room7', 'Room8', 'Room9', 'Room10'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$firstName $lastName'),
              Text(email),
              ButtonWidget(
                text: share,
                onClick: () {
                  // TODO
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    rooms
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(my),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(other),
                  ),
                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(roomsList[index]),
                  );
                },
                itemCount: roomsList.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum RoomsType {
  my,
  other
}

class LocationsLogicState {

  static const int pageSize = 20;

  final List<LocationModel> locations;
  final int curPage;
  final bool isLast;

  final String? snackBar;
  final bool loading;


  LocationsLogicState({
    required this.locations,
    required this.curPage,
    required this.isLast,
    required this.snackBar,
    required this.loading
  });

  LocationsLogicState copyWith({
    List<LocationModel>? locations,
    int? curPage,
    bool? isLast,
    String? snackBar,
    bool? loading
  }) => LocationsLogicState(
      locations: locations ?? this.locations,
      curPage: curPage ?? this.curPage,
      isLast: isLast ?? this.isLast,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class LocationsCubit extends Cubit<LocationsLogicState> {

  final LocationInteractor _locationInteractor;

  LocationsCubit(
      this._locationInteractor
  ) : super(
    LocationsLogicState(
      locations: [],
      curPage: 0,
      isLast: false,
      snackBar: null,
      loading: true
    )
  );

  Future<void> onStart() async {
    Result result = await _locationInteractor.getMyLocations(
      state.curPage,
      LocationsLogicState.pageSize
    );
    if (result is SuccessResult<ContainerForList<LocationModel>>) {
      emit(state.copyWith(loading: false, locations: result.data.results));
    } else if (result is ErrorResult) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    }
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}
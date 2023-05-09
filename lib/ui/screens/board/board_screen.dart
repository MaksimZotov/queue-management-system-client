import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/location/change/base/location_change_model.dart';
import 'package:queue_management_system_client/domain/models/location/client.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/board.dart';
import '../../../domain/models/location/location_state.dart';
import '../../router/routes_config.dart';

class BoardWidget extends BaseWidget<BoardConfig> {

  const BoardWidget({
    super.key,
    required super.config,
    required super.emitConfig,
  });

  @override
  State<BoardWidget> createState() => _BoardState();
}

class _BoardState extends BaseState<BoardWidget, BoardLogicState, BoardCubit> {

  @override
  Widget getWidget(
      BuildContext context,
      BoardLogicState state,
      BoardWidget widget
  ) {
    List<List<Client>> clientsColumns = state.board.clientsColumns;
    if (clientsColumns.isEmpty) {
      return Row(children: const []);
    }
    int startIndex = state.page * state.config.columnsAmount;
    int lastIndex = startIndex + state.config.columnsAmount - 1;
    List<List<Client>> sublistColumns = clientsColumns.sublist(
        startIndex,
        clientsColumns.length < lastIndex + 1
            ? null
            : lastIndex + 1
    );

    return Row(
      children: sublistColumns.asMap().map((i, rows) =>
        MapEntry(
          i,
          Expanded(
            child: Container(
              color: i.isEven ? Colors.teal[100] : Colors.teal[200],
              child: Column(
                children: rows.map((client) =>
                  Expanded(
                    child: Card(
                      color: Colors.blueGrey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0)
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: client.queue == null
                                    ? Colors.blueGrey[300]
                                    : Colors.green[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${client.code}:',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40
                                        ),
                                      )
                                    )
                                  )
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Card(
                                color: client.queue == null
                                  ? Colors.blueGrey[300]
                                  : Colors.green[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          client.queue?.name ?? '-',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40
                                          ),
                                        )
                                      )
                                    )
                                )
                              )
                            )
                          ],
                        ),
                      ),
                    )
                  )
                ).toList() + [
                  Expanded(
                    flex: state.config.rowsAmount - rows.length,
                    child: Container()
                  )
                ]
              ),
            ),
          ),
        )
      ).values.toList()
    );
  }

  @override
  BoardCubit getCubit() => statesAssembler.getBoardCubit(widget.config);
}

class BoardLogicState extends BaseLogicState {

  final BoardConfig config;
  final Board board;
  final int page;
  final LocationState? locationState;

  BoardLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.board,
    required this.page,
    required this.locationState
  });

  @override
  BoardLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    Board? board,
    int? page,
    LocationState? locationState
  }) => BoardLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      board: board ?? this.board,
      page: page ?? this.page,
      locationState: locationState ?? this.locationState
  );
}

@injectable
class BoardCubit extends BaseCubit<BoardLogicState> {

  static const String _locationTopic = '/topic/locations/';

  final LocationInteractor _locationInteractor;
  final SocketInteractor _socketInteractor;

  Timer? _timer;

  List<LocationChange> changes = [];

  BoardCubit(
    this._locationInteractor,
    this._socketInteractor,
    @factoryParam BoardConfig config
  ) : super(
      BoardLogicState(
          config: config,
          board: Board([]),
          page: 0,
          locationState: LocationState(
              id: null,
              clients: []
          )
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    _socketInteractor.connectToSocket<LocationChange>(
      _locationTopic + state.config.locationId.toString(),
      () async => {
        await _locationInteractor.getLocationState(
            state.config.locationId
        )..onSuccess((result) {
          _setLocationState(result.data);
        })..onError((result) {
          showError(result);
        })
      },
      _handleLocationChange,
      (error) => { /* Do nothing */ }
    );

    _startSwitchingPages();
  }

  @override
  Future<void> close() async {
    _socketInteractor.disconnectFromSocket(
        _locationTopic + state.config.locationId.toString()
    );
    _timer?.cancel();
    return super.close();
  }

  void _startSwitchingPages() async {
    _timer = Timer.periodic(Duration(seconds: state.config.switchFrequency), (timer) {
      int nextPage = state.page + 1;
      if (nextPage * state.config.columnsAmount >= state.board.clientsColumns.length) {
        emit(state.copy(page: 0));
      } else {
        emit(state.copy(page: state.page + 1));
      }
    });
  }

  void _setLocationState(LocationState locationState) {
    LocationState actualLocationState = _locationInteractor.transformLocation(
        locationState,
        changes
    );

    emit(
        state.copy(
            locationState: actualLocationState,
            board: Board.fromLocationState(actualLocationState, state.config.rowsAmount)
        )
    );

    changes.clear();
  }

  void _handleLocationChange(LocationChange locationChange) {
    LocationState? prevLocationState = state.locationState;
    changes.add(locationChange);
    if (prevLocationState != null) {
      LocationState newLocationState = _locationInteractor.transformLocation(
          prevLocationState,
          changes
      );
      changes.clear();
      _setLocationState(newLocationState);
    }
  }
}
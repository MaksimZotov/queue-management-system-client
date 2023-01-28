import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/board_model.dart';
import '../../../domain/models/location/board_position.dart';
import '../../../domain/models/location/board_queue.dart';
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
    List<BoardQueue> queues = state.board.queues;
    if (queues.isEmpty) {
      return Row(children: const []);
    }
    int startIndex = state.page * BoardLogicState._pageSize;
    int lastIndex = startIndex + BoardLogicState._pageSize - 1;
    List<BoardQueue> sublist = queues.sublist(
        startIndex,
        queues.length < lastIndex + 1
            ? null
            : lastIndex + 1
    );

    return Row(
      children: sublist.asMap().map((i, queue) =>
        MapEntry(
          i,
          Expanded(
            child: Container(
              color: i.isEven ? Colors.teal[100] : Colors.teal[200],
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.blueGrey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0)
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            queue.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                          ),
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, nestedIndex) {
                        BoardPosition boardPosition = state
                          .board
                          .queues[i]
                          .positions[nestedIndex];
                        return Card(
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
                                Card(
                                  color: Colors.blueGrey[300],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${boardPosition.number}:',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Card(
                                    color: Colors.blueGrey[300],
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          boardPosition.publicCode.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18
                                          ),
                                        )
                                      )
                                    )
                                  )
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: queue.positions.length,
                    )
                  )
                ],
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

  static const int _pageSize = 5;

  final BoardConfig config;
  final BoardModel board;
  final int page;

  BoardLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.board,
    required this.page
  });

  @override
  BoardLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    BoardModel? board,
    int? page
  }) => BoardLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      board: board ?? this.board,
      page: page ?? this.page
  );
}

@injectable
class BoardCubit extends BaseCubit<BoardLogicState> {

  static const String _locationTopic = '/topic/boards/';

  final LocationInteractor _locationInteractor;
  final SocketInteractor _socketInteractor;

  Timer? _timer;

  BoardCubit(
    this._locationInteractor,
    this._socketInteractor,
    @factoryParam BoardConfig config
  ) : super(
      BoardLogicState(
          config: config,
          board: BoardModel(
            queues: []
          ),
          page: 0
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    await _locationInteractor.getLocationBoard(
        state.config.locationId
    )..onSuccess((result) {
      emit(state.copy(board: result.data));
      hideLoad();
    })..onError((result) {
      showError(result);
    });

    _socketInteractor.connectToSocket<BoardModel>(
      _locationTopic + state.config.locationId.toString(),
      () => { /* Do nothing */ },
      (board) => {
        emit(state.copy(board: board))
      },
      (error) => { /* Do nothing */ }
    );

    _startSwitchPages();
  }

  @override
  Future<void> close() async {
    _socketInteractor.disconnectFromSocket(
        _locationTopic + state.config.locationId.toString()
    );
    _timer?.cancel();
    return super.close();
  }

  void _startSwitchPages() async {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      int nextPage = state.page + 1;
      if (nextPage * BoardLogicState._pageSize >= state.board.queues.length) {
        emit(state.copy(page: 0));
      } else {
        emit(state.copy(page: state.page + 1));
      }
    });
  }
}
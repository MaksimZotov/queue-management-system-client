import 'dart:async';
import 'dart:html';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/board/board_position.dart';
import 'package:queue_management_system_client/domain/models/board/board_queue.dart';
import 'package:queue_management_system_client/domain/models/client/client_join_info_model.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/client_item_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/board_interactor.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../../domain/models/board/board_model.dart';
import '../../router/routes_config.dart';


class BoardWidget extends StatefulWidget {
  final BoardConfig config;

  const BoardWidget({super.key, required this.config});

  @override
  State<BoardWidget> createState() => _BoardState();
}

class _BoardState extends State<BoardWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BoardCubit>(
      create: (context) => statesAssembler.getBoardCubit(widget.config)..onStart(),
      child: BlocConsumer<BoardCubit, BoardLogicState>(

        listener: (context, state) {
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => getBoard(state),
      ),
    );
  }

  Widget getBoard(BoardLogicState state) {
    List<BoardQueue> queues = state.board.queues;
    if (queues.isEmpty) {
      return Row(children: const []);
    }
    int startIndex = state.page * BoardLogicState.pageSize;
    int lastIndex = startIndex + BoardLogicState.pageSize - 1;
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                              BoardPosition boardPosition = state.board.queues[i].positions[nestedIndex];
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
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                                                    style: const TextStyle(color: Colors.white, fontSize: 18),
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
}

class BoardLogicState {

  static int pageSize = 5;

  final BoardConfig config;

  final BoardModel board;
  final int page;

  final String? snackBar;
  final bool loading;

  BoardLogicState({
    required this.config,
    required this.board,
    required this.page,
    required this.snackBar,
    required this.loading,
  });

  BoardLogicState copyWith({
    BoardModel? board,
    int? page,
    String? snackBar,
    bool? loading,
  }) => BoardLogicState(
      config: config,
      board: board ?? this.board,
      page: page ?? this.page,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class BoardCubit extends Cubit<BoardLogicState> {

  static String _locationTopic = '/topic/boards/';

  final BoardInteractor boardInteractor;
  final SocketInteractor socketInteractor;

  Timer? _timer;

  BoardCubit(
    this.boardInteractor,
    this.socketInteractor,
    @factoryParam BoardConfig config
  ) : super(
      BoardLogicState(
          config: config,
          board: BoardModel(
            queues: []
          ),
          page: 0,
          snackBar: null,
          loading: false
      )
  );

  Future<void> onStart() async {
    emit(state.copyWith(loading: true));
    await boardInteractor.getBoard(state.config.locationId)..onSuccess((result) {
      emit(state.copyWith(loading: false, board: result.data));
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
      emit(state.copyWith(snackBar: null));
    });

    socketInteractor.connectToSocket<BoardModel>(
      _locationTopic + state.config.locationId.toString(),
      () => { /* Do nothing */ },
      (board) => {
        emit(state.copyWith(board: board))
      },
      (error) => { /* Do nothing */ }
    );

    _startSwitchPages();
  }

  @override
  Future<void> close() async {
    socketInteractor.disconnectFromSocket(_locationTopic + state.config.locationId.toString());
    _timer?.cancel();
    return super.close();
  }

  void _startSwitchPages() async {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if ((state.page + 1) * BoardLogicState.pageSize >= state.board.queues.length) {
        emit(state.copyWith(page: 0));
      } else {
        emit(state.copyWith(page: state.page + 1));
      }
    });
  }
}
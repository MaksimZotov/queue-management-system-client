import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/queue/queue.dart';
import 'package:queue_management_system_client/ui/screens/queue/create_queue.dart';
import 'package:queue_management_system_client/ui/widgets/queue_item.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../router/routes_config.dart';
import 'delete_queue.dart';

class QueuesWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;
  final QueuesConfig config;

  QueuesWidget({super.key, required this.config, required this.emitConfig});

  @override
  State<QueuesWidget> createState() => _QueuesState();
}

class _QueuesState extends State<QueuesWidget> {
  final titleStart = 'Локация: ';
  final String createLocationHint = 'Создать локацию';

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QueuesCubit>(
      create: (context) => statesAssembler.getQueuesCubit(widget.config)..onStart(),
      lazy: true,
      child: BlocBuilder<QueuesCubit, QueuesLogicState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(
                state.locationName.isEmpty ? '' : titleStart + state.locationName
            ),
          ),
          body: ListView.builder(
            controller: _scrollController
              ..addListener(() {
                if (_scrollController.offset ==
                    _scrollController.position.maxScrollExtent
                ) {
                  BlocProvider.of<QueuesCubit>(context).loadNext();
                }
              }),
            itemBuilder: (context, index) {
              return QueueItemWidget(
                queue: state.queues[index],
                onClick: (queue) => widget.emitConfig(
                    QueueConfig(
                        username: state.config.username,
                        locationId: state.config.locationId,
                        queueId: queue.id!
                    )
                ),
                onDelete: (location) => showDialog(
                    context: context,
                    builder: (context) => DeleteQueueWidget(
                        config: DeleteQueueConfig(
                            id: location.id!
                        )
                    )
                ).then((result) {
                  if (result is DeleteQueueResult) {
                    BlocProvider.of<QueuesCubit>(context).deleteQueue(result);
                  }
                }),
              );
            },
            itemCount: state.queues.length,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => const CreateQueueWidget()
            ).then((result) {
              if (result is CreateQueueResult) {
                BlocProvider.of<QueuesCubit>(context).createQueue(result);
              }
            }),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class QueuesLogicState {

  static const int pageSize = 30;

  final QueuesConfig config;

  final String locationName;

  final List<QueueModel> queues;
  final int curPage;
  final bool isLast;
  
  final String? snackBar;
  final bool loading;


  QueuesLogicState({
    required this.config,
    required this.locationName,
    required this.queues,
    required this.curPage,
    required this.isLast,
    required this.snackBar,
    required this.loading,
  });

  QueuesLogicState copyWith({
    String? locationName,
    List<QueueModel>? queues,
    int? curPage,
    bool? isLast,
    String? snackBar,
    bool? loading,
  }) => QueuesLogicState(
      config: config,
      locationName: locationName ?? this.locationName,
      queues: queues ?? this.queues,
      curPage: curPage ?? this.curPage,
      isLast: isLast ?? this.isLast,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class QueuesCubit extends Cubit<QueuesLogicState> {

  final QueueInteractor queueInteractor;
  final LocationInteractor locationInteractor;

  QueuesCubit({
    required this.queueInteractor,
    required this.locationInteractor,
    @factoryParam required QueuesConfig config
  }) : super(
    QueuesLogicState(
      config: config,
      locationName: '',
      queues: [],
      curPage: 0,
      isLast: false,
      snackBar: null,
      loading: false
    )
  );

  Future<void> onStart() async {
    await locationInteractor.getLocation(state.config.locationId)..onSuccess((result) async {
      emit(state.copyWith(locationName: result.data.name));
      await loadNext();
    })..onError((result) {
      emit(state.copyWith(snackBar: result.description));
    });
  }

  Future<void> loadNext() async {
    if (state.loading || state.isLast) {
      return;
    }
    emit(state.copyWith(loading: true));
    await queueInteractor.getQueues(
        state.config.locationId,
        state.curPage,
        QueuesLogicState.pageSize
    )..onSuccess((result) {
      emit(
          state.copyWith(
              loading: false,
              queues: state.queues + result.data.results,
              curPage: state.curPage + 1,
              isLast: result.data.isLast
          )
      );
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    });
  }

  Future<void> createQueue(CreateQueueResult result) async {
    emit(state.copyWith(loading: true));
    await queueInteractor.createQueue(
        state.config.locationId,
        QueueModel(
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

  Future deleteQueue(DeleteQueueResult result) async {
    emit(state.copyWith(loading: true));
    await queueInteractor.deleteQueue(result.id)..onSuccess((result) {
      _reload();
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    });
  }

  Future<void> _reload() async {
    emit(state.copyWith(
      loading: false,
      queues: [],
      curPage: 0,
      isLast: false
    ));
    loadNext();
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}
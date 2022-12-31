import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/domain/models/queue/queue.dart';
import 'package:queue_management_system_client/ui/screens/location/create_location.dart';
import 'package:queue_management_system_client/ui/screens/location/delete_location.dart';
import 'package:queue_management_system_client/ui/screens/queue/create_queue.dart';
import 'package:queue_management_system_client/ui/screens/queue/queue.dart';
import 'package:queue_management_system_client/ui/widgets/location_item.dart';
import 'package:queue_management_system_client/ui/widgets/queue_item.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/container_for_list.dart';
import '../../../domain/models/base/result.dart';
import '../../navigation/route_generator.dart';
import 'delete_queue.dart';

class QueuesParams {
  final int locationId;
  final String locationName;

  QueuesParams({
    required this.locationId,
    required this.locationName
  });
}

class QueuesWidget extends StatefulWidget {
  final QueuesParams params;

  const QueuesWidget({super.key, required this.params});

  @override
  State<QueuesWidget> createState() => _QueuesState();
}

class _QueuesState extends State<QueuesWidget> {
  late final String title = 'Очереди в "${widget.params.locationName}"';
  final String createLocationHint = 'Создать локацию';

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QueuesCubit>(
      create: (context) => statesAssembler.getQueuesCubit(widget.params)..onStart(),
      lazy: true,
      child: BlocBuilder<QueuesCubit, QueuesLogicState>(
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
                  BlocProvider.of<QueuesCubit>(context).loadNext();
                }
              }),
            itemBuilder: (context, index) {
              return QueueItemWidget(
                queue: state.queues[index],
                onClick: (queue) => Navigator.of(context).pushNamed(
                    Routes.queue,
                    arguments: QueueParams(
                        queueId: queue.id!,
                        queueName: queue.name,
                        queueDescription: queue.description
                    )
                ),
                onDelete: (location) => showDialog(
                    context: context,
                    builder: (context) => DeleteQueueWidget(
                        params: DeleteQueueParams(
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

  final QueuesParams params;

  final List<QueueModel> queues;
  final int curPage;
  final bool isLast;
  
  final String? snackBar;
  final bool loading;


  QueuesLogicState({
    required this.params,
    required this.queues,
    required this.curPage,
    required this.isLast,
    required this.snackBar,
    required this.loading,
  });

  QueuesLogicState copyWith({
    List<QueueModel>? locations,
    int? curPage,
    bool? isLast,
    String? snackBar,
    bool? loading,
  }) => QueuesLogicState(
      params: params,
      queues: locations ?? this.queues,
      curPage: curPage ?? this.curPage,
      isLast: isLast ?? this.isLast,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class QueuesCubit extends Cubit<QueuesLogicState> {

  final QueueInteractor queueInteractor;

  QueuesCubit({
    required this.queueInteractor,
    @factoryParam required QueuesParams params
  }) : super(
    QueuesLogicState(
      params: params,
      queues: [],
      curPage: 0,
      isLast: false,
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
    await queueInteractor.getQueues(
        state.params.locationId,
        state.curPage,
        QueuesLogicState.pageSize
    )..onSuccess((result) {
      emit(
          state.copyWith(
              loading: false,
              locations: state.queues + result.data.results,
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
        state.params.locationId,
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
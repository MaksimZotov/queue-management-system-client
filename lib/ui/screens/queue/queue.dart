import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue.dart';
import 'package:queue_management_system_client/domain/models/queue/queue.dart';
import 'package:queue_management_system_client/ui/widgets/client_item.dart';

import '../../../di/assemblers/states_assembler.dart';

class QueueParams {
  final int queueId;
  final String queueName;
  final String queueDescription;

  QueueParams({
    required this.queueId,
    required this.queueName,
    required this.queueDescription
  });
}

class QueueWidget extends StatefulWidget {
  final QueueParams params;

  const QueueWidget({super.key, required this.params});

  @override
  State<QueueWidget> createState() => _QueueState();
}

class _QueueState extends State<QueueWidget> {
  late final String title = 'Очередь "${widget.params.queueName}"';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QueueCubit>(
      create: (context) => statesAssembler.getQueueCubit(widget.params)..onStart(),
      lazy: true,
      child: BlocBuilder<QueueCubit, QueueLogicState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              return ClientItemWidget(
                client: state.queueState.clients![index],
                onNotify: BlocProvider.of<QueueCubit>(context).notify,
                onServe: BlocProvider.of<QueueCubit>(context).serve,
              );
            },
            itemCount: state.queueState.clients!.length,
          ),
        ),
      ),
    );
  }
}

class QueueLogicState {

  final QueueParams params;

  final QueueModel queueState;

  final String? snackBar;
  final bool loading;
  
  QueueLogicState({
    required this.params,
    required this.queueState,
    required this.snackBar,
    required this.loading,
  });

  QueueLogicState copyWith({
    QueueModel? queueState,
    String? snackBar,
    bool? loading,
  }) => QueueLogicState(
      params: params,
      queueState: queueState ?? this.queueState,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class QueueCubit extends Cubit<QueueLogicState> {

  final QueueInteractor queueInteractor;

  QueueCubit({
    required this.queueInteractor,
    @factoryParam required QueueParams params
  }) : super(
      QueueLogicState(
          params: params,
          queueState: QueueModel(
            id: params.queueId,
            name: params.queueName,
            description: params.queueDescription,
            clients: []
          ),
          snackBar: null,
          loading: false
      )
  );

  Future<void> onStart() async {
    emit(state.copyWith(loading: true));
    await queueInteractor.getQueueState(state.params.queueId)..onSuccess((result) {
      emit(state.copyWith(loading: false, queueState: result.data));
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    });
  }

  Future<void> notify(ClientInQueueModel client) async {
    await queueInteractor.notifyClientInQueue(state.params.queueId, client.id);
  }

  Future<void> serve(ClientInQueueModel client) async {
    await queueInteractor.serveClientInQueue(state.params.queueId, client.id);
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/ui/widgets/client_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../router/routes_config.dart';


class QueueWidget extends StatefulWidget {
  final QueueConfig config;

  const QueueWidget({super.key, required this.config});

  @override
  State<QueueWidget> createState() => _QueueState();
}

class _QueueState extends State<QueueWidget> {
  final titleStart = 'Очередь: ';
  final linkCopied = 'Ссылка скопирована';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QueueCubit>(
      create: (context) => statesAssembler.getQueueCubit(widget.config)..onStart(),
      child: BlocConsumer<QueueCubit, QueueLogicState>(

        listener: (context, state) {
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(
                state.queueState.name.isEmpty ? '' : titleStart + state.queueState.name
            ),
            actions: state.queueState.ownerUsername != null
              ? [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => BlocProvider.of<QueueCubit>(context).share(linkCopied),
                ),
              ]
              : null,
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

  final QueueConfig config;

  final QueueModel queueState;

  final String? snackBar;
  final bool loading;
  
  QueueLogicState({
    required this.config,
    required this.queueState,
    required this.snackBar,
    required this.loading,
  });

  QueueLogicState copyWith({
    QueueModel? queueState,
    String? snackBar,
    bool? loading,
  }) => QueueLogicState(
      config: config,
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
    @factoryParam required QueueConfig config
  }) : super(
      QueueLogicState(
          config: config,
          queueState: QueueModel(
            id: config.queueId,
            name: '',
            description: '',
            clients: []
          ),
          snackBar: null,
          loading: false
      )
  );

  Future<void> onStart() async {
    emit(state.copyWith(loading: true));
    await queueInteractor.getQueueState(state.config.queueId)..onSuccess((result) {
      emit(state.copyWith(loading: false, queueState: result.data));
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    });

    queueInteractor.connectToQueueSocket(
      state.config.queueId,
      () => { /* Do nothing */ },
      (queue) => emit(state.copyWith(queueState: queue)),
      (error) => { /* Do nothing */ }
    );
  }

  Future<void> notify(ClientInQueueModel client) async {
    await queueInteractor.notifyClientInQueue(state.config.queueId, client.email);
  }

  Future<void> serve(ClientInQueueModel client) async {
    await queueInteractor.serveClientInQueue(state.config.queueId, client.email);
  }

  Future<void> share(String notificationText) async {
    String username = state.queueState.ownerUsername!;
    int locationId = state.config.locationId;
    int queueId = state.config.queueId;
    await Clipboard.setData(
        ClipboardData(
            text: '${ServerApi.clientUrl}/$username/locations/$locationId/queues/$queueId/client'
        )
    );
    emit(state.copyWith(snackBar: notificationText));
    emit(state.copyWith(snackBar: null));
  }

  @override
  Future<void> close() async {
    queueInteractor.disconnectFromQueueSocket(state.config.queueId);
    return super.close();
  }
}
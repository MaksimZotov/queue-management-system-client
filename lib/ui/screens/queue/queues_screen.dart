import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/queue/create_queue_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/queue_item_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import 'delete_queue_dialog.dart';

class QueuesWidget extends BaseWidget<QueuesConfig> {

  const QueuesWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<QueuesWidget> createState() => _QueuesState();
}

class _QueuesState extends BaseState<
    QueuesWidget,
    QueuesLogicState,
    QueuesCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      QueuesLogicState state,
      QueuesWidget widget
  ) => Scaffold(
    appBar: AppBar(
      title: Text(
          state.locationName.isEmpty
              ? ''
              : getLocalizations(context).queues
      )
    ),
    body: ListView.builder(
      itemBuilder: (context, index) {
        return QueueItemWidget(
          queue: state.queues[index],
          onTap: (queue) => widget.emitConfig(
            QueueConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId,
                queueId: queue.id
            )
          ),
          onDelete: (location) => showDialog(
              context: context,
              builder: (context) => DeleteQueueWidget(
                  config: DeleteQueueConfig(id: location.id)
              )
          ).then((result) {
            if (result is DeleteQueueResult) {
              getCubitInstance(context).handleDeleteQueueResult(result);
            }
          }
          ),
        );
      },
      itemCount: state.queues.length,
    ),
    floatingActionButton: FloatingActionButton(
      tooltip: getLocalizations(context).createQueue,
      onPressed: () => showDialog(
          context: context,
          builder: (context) => CreateQueueWidget(
              config: CreateQueueConfig(
                  locationId: state.config.locationId
              )
          )
      ).then((result) {
        if (result is CreateQueueResult) {
          getCubitInstance(context).handleCreateQueueResult(
              result,
              getLocalizations(context).locationDoesNotContainSpecialists
          );
        }
      }),
      child: const Icon(Icons.add),
    ),
  );

  @override
  QueuesCubit getCubit() => statesAssembler.getQueuesCubit(widget.config);
}

class QueuesLogicState extends BaseLogicState {

  final QueuesConfig config;

  final String? ownerEmail;
  final String locationName;

  final List<QueueModel> queues;

  QueuesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.ownerEmail,
    required this.locationName,
    required this.queues,
  });
  
  @override
  QueuesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? ownerEmail,
    String? locationName,
    List<QueueModel>? queues,
  }) => QueuesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      locationName: locationName ?? this.locationName,
      queues: queues ?? this.queues
  );
}

@injectable
class QueuesCubit extends BaseCubit<QueuesLogicState> {
  final QueueInteractor queueInteractor;
  final LocationInteractor locationInteractor;

  QueuesCubit(
      this.queueInteractor,
      this.locationInteractor,
      @factoryParam QueuesConfig config
  ) : super(
      QueuesLogicState(
            config: config,
            ownerEmail: null,
            locationName: '',
            queues: []
      )
  );

  @override
  Future<void> onStart() async {
    await locationInteractor.getLocation(state.config.locationId)
      ..onSuccess((result) async {
        LocationModel location = result.data;
        emit(
            state.copy(
                ownerEmail: location.ownerEmail,
                locationName: location.name
            )
        );
        await _load();
      })
      ..onError((result) {
        showError(result);
      });
  }

  void handleCreateQueueResult(
      CreateQueueResult result,
      String emptySpecialistsError
  ) {
    QueueModel? queueModel = result.queueModel;
    if (queueModel == null) {
      showSnackBar(emptySpecialistsError);
    } else {
      emit(state.copy(queues: state.queues + [queueModel]));
    }
  }

  void handleDeleteQueueResult(DeleteQueueResult result) {
    emit(
        state.copy(
            queues: state.queues
              ..removeWhere((element) => element.id == result.id)
        )
    );
  }

  Future<void> _load() async {
    await queueInteractor.getQueues(state.config.locationId)
      ..onSuccess((result) {
        emit(state.copy(queues: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}

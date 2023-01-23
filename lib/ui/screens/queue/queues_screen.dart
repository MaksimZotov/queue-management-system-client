import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
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
              : getLocalizations(context).locationPattern(state.locationName)
      ),
      actions: state.ownerUsername != null
          ? (state.hasRights ? <Widget>[
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => widget.emitConfig(
                    RightsConfig(
                        username: widget.config.username,
                        locationId: widget.config.locationId
                    )
                )
            )
          ] : <Widget>[]) +
          [
            IconButton(
                icon: const Icon(Icons.desktop_windows_outlined),
                onPressed: () => widget.emitConfig(
                    BoardConfig(
                        username: widget.config.username,
                        locationId: widget.config.locationId
                    )
                )
            ),
            IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: getCubitInstance(context).downloadQrCode
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => getCubitInstance(context).share(
                  getLocalizations(context).linkCopied
              ),
            ),
          ]
          : null,
    ),
    body: ListView.builder(
      itemBuilder: (context, index) {
        return QueueItemWidget(
          queue: state.queues[index],
          onClick: (queue) => widget.emitConfig(
              state.hasRights ? QueueConfig(
                  username: state.config.username,
                  locationId: state.config.locationId,
                  queueId: queue.id!
              ) : ClientConfig(
                  username: state.config.username,
                  locationId: state.config.locationId,
                  queueId: queue.id!
              )
          ),
          onDelete: (location) => showDialog(
              context: context,
              builder: (context) => DeleteQueueWidget(
                  config: DeleteQueueConfig(id: location.id!)
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
    floatingActionButton: state.hasRights
        ? FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => CreateQueueWidget(
                  config: CreateQueueConfig(
                    locationId: state.config.locationId
                  )
              )
          ).then((result) {
            if (result is CreateQueueResult) {
              getCubitInstance(context).handleCreateQueueResult(result);
            }
          }),
          child: const Icon(Icons.add),
        )
        : null,
  );

  @override
  QueuesCubit getCubit() => statesAssembler.getQueuesCubit(widget.config);
}

class QueuesLogicState extends BaseLogicState {

  final QueuesConfig config;

  final String? ownerUsername;
  final String locationName;
  final bool hasRights;

  final List<QueueModel> queues;

  QueuesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.ownerUsername,
    required this.locationName,
    required this.hasRights,
    required this.queues,
  });
  
  @override
  QueuesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? ownerUsername,
    String? locationName,
    List<QueueModel>? queues,
    bool? hasRights
  }) => QueuesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
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
            ownerUsername: null,
            locationName: '',
            hasRights: false,
            queues: []
      )
  );

  @override
  Future<void> onStart() async {
    await locationInteractor.getLocation(
        state.config.locationId, state.config.username
    )
      ..onSuccess((result) async {
        emit(
            state.copy(
                ownerUsername: result.data.ownerUsername,
                locationName: result.data.name,
                hasRights: result.data.hasRights
            )
        );
        await _load();
      })
      ..onError((result) {
        showError(result);
      });
  }

  void handleCreateQueueResult(CreateQueueResult result) {
    emit(state.copy(queues: state.queues + [result.queueModel]));
  }

  void handleDeleteQueueResult(DeleteQueueResult result) {
    emit(
        state.copy(
            queues: state.queues
              ..removeWhere((element) => element.id == result.id)
        )
    );
  }

  Future<void> share(String notificationText) async {
    String username = state.ownerUsername!;
    int locationId = state.config.locationId;
    await Clipboard.setData(
        ClipboardData(
            text: '${ServerApi.clientUrl}/$username/locations/$locationId/queues'
        )
    );
    showSnackBar(notificationText);
  }

  Future<void> downloadQrCode() async {
    String username = state.ownerUsername!;
    int locationId = state.config.locationId;
    String url = '${ServerApi.clientUrl}/$username/locations/$locationId/queues';

    final image = await QrPainter(
      data: url,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImageData(1024);

    if (image != null) {
      await FileSaver.instance.saveFile(
          url,
          image.buffer.asUint8List(),
          'png',
          mimeType: MimeType.PNG
      );
    }
  }

  Future<void> _load() async {
    await queueInteractor.getQueues(
        state.config.locationId,
        state.config.username
    )
      ..onSuccess((result) {
        emit(state.copy(queues: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}

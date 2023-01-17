import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/ui/screens/queue/create_queue_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/queue_item_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../router/routes_config.dart';
import 'delete_queue_dialog.dart';

class QueuesWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;
  final QueuesConfig config;

  QueuesWidget({super.key, required this.config, required this.emitConfig});

  @override
  State<QueuesWidget> createState() => _QueuesState();
}

class _QueuesState extends State<QueuesWidget> {
  final String titleStart = 'Локация: ';
  final String createLocationHint = 'Создать локацию';
  final String linkCopied = 'Ссылка скопирована';

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QueuesCubit>(
      create: (context) => statesAssembler.getQueuesCubit(widget.config)..onStart(),
      child: BlocConsumer<QueuesCubit, QueuesLogicState>(

        listener: (context, state) {
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(state.locationName.isEmpty ? '' : titleStart + state.locationName),
            actions: state.ownerUsername != null
                ? (state.hasRules ? <Widget>[
                  IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => widget.emitConfig(
                          RulesConfig(
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
                      onPressed: BlocProvider.of<QueuesCubit>(context).downloadQrCode
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => BlocProvider.of<QueuesCubit>(context).share(linkCopied),
                  ),
                ]
                : null,
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              return QueueItemWidget(
                queue: state.queues[index],
                onClick: (queue) => widget.emitConfig(
                  state.hasRules ? QueueConfig(
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
                    BlocProvider.of<QueuesCubit>(context).deleteQueue(result);
                  }
                }
                ),
              );
            },
            itemCount: state.queues.length,
          ),
          floatingActionButton: state.hasRules
            ? FloatingActionButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const CreateQueueWidget()).then((result) {
                if (result is CreateQueueResult) {
                  BlocProvider.of<QueuesCubit>(context).createQueue(result);
                }
              }),
              child: const Icon(Icons.add),
            ) : null,
        ),
      ),
    );
  }
}

class QueuesLogicState {

  final QueuesConfig config;

  final String? ownerUsername;
  final String locationName;
  final bool hasRules;

  final List<QueueModel> queues;

  final String? snackBar;
  final bool loading;

  QueuesLogicState({
    required this.config,
    required this.ownerUsername,
    required this.locationName,
    required this.hasRules,
    required this.queues,
    required this.snackBar,
    required this.loading,
  });

  QueuesLogicState copyWith({
    String? ownerUsername,
    String? locationName,
    List<QueueModel>? queues,
    bool? hasRules,
    String? snackBar,
    bool? loading,
  }) =>
      QueuesLogicState(
          config: config,
          ownerUsername: ownerUsername ?? this.ownerUsername,
          locationName: locationName ?? this.locationName,
          hasRules: hasRules ?? this.hasRules,
          queues: queues ?? this.queues,
          snackBar: snackBar,
          loading: loading ?? this.loading);
}

@injectable
class QueuesCubit extends Cubit<QueuesLogicState> {
  final QueueInteractor queueInteractor;
  final LocationInteractor locationInteractor;

  QueuesCubit({required this.queueInteractor,
      required this.locationInteractor,
      @factoryParam required QueuesConfig config
  }) : super(
      QueuesLogicState(
            config: config,
            ownerUsername: null,
            locationName: '',
            hasRules: false,
            queues: [],
            snackBar: null,
            loading: false
      )
  );

  Future<void> onStart() async {
    await locationInteractor.getLocation(
        state.config.locationId, state.config.username
    )
      ..onSuccess((result) async {
        emit(
            state.copyWith(
                ownerUsername: result.data.ownerUsername,
                locationName: result.data.name,
                hasRules: result.data.hasRules
            )
        );
        await _reload();
      })
      ..onError((result) {
        emit(state.copyWith(snackBar: result.description));
        emit(state.copyWith(snackBar: null));
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
    )
      ..onSuccess((result) {
        _reload();
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future deleteQueue(DeleteQueueResult result) async {
    emit(state.copyWith(loading: true));
    await queueInteractor.deleteQueue(result.id)
      ..onSuccess((result) {
        _reload();
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future<void> _reload() async {
    await queueInteractor.getQueues(state.config.locationId, state.config.username)
      ..onSuccess((result) {
        emit(state.copyWith(
          loading: false,
          queues: result.data.results,
        ));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future<void> share(String notificationText) async {
    String username = state.ownerUsername!;
    int locationId = state.config.locationId;
    await Clipboard.setData(
        ClipboardData(
            text: '${ServerApi.clientUrl}/$username/locations/$locationId/queues'
        )
    );
    emit(state.copyWith(snackBar: notificationText));
    emit(state.copyWith(snackBar: null));
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
}

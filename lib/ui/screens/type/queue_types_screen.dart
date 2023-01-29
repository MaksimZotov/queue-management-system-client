import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/models/location/queue_type_model.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/queue_type_item_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import 'create_queue_type_dialog.dart';
import 'delete_queue_type_dialog.dart';

class QueueTypesWidget extends BaseWidget<QueueTypesConfig> {

  const QueueTypesWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<QueueTypesWidget> createState() => _QueueTypesState();
}

class _QueueTypesState extends BaseState<
    QueueTypesWidget,
    QueueTypesLogicState,
    QueueTypesCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      QueueTypesLogicState state,
      QueueTypesWidget widget
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
        return QueueTypeItemWidget(
          queueType: state.queueTypes[index],
          onDelete: (location) => showDialog(
              context: context,
              builder: (context) => DeleteQueueTypeWidget(
                  config: DeleteQueueTypeConfig(
                      locationId: location.id,
                      queueTypeId: state.queueTypes[index].id
                  )
              )
          ).then((result) {
            if (result is DeleteQueueTypeResult) {
              getCubitInstance(context).handleDeleteQueueTypeResult(result);
            }
          }
          ),
        );
      },
      itemCount: state.queueTypes.length,
    ),
    floatingActionButton: state.hasRights
        ? FloatingActionButton(
      onPressed: () => showDialog(
          context: context,
          builder: (context) => CreateQueueTypeWidget(
              config: CreateQueueTypeConfig(
                  locationId: state.config.locationId,
                  serviceIds: []
              )
          )
      ).then((result) {
        if (result is CreateQueueTypeResult) {
          getCubitInstance(context).handleCreateQueueTypeResult(result);
        }
      }),
      child: const Icon(Icons.add),
    )
        : null,
  );

  @override
  QueueTypesCubit getCubit() => statesAssembler.getQueueTypesCubit(widget.config);
}

class QueueTypesLogicState extends BaseLogicState {

  final QueueTypesConfig config;

  final String? ownerUsername;
  final String locationName;
  final bool hasRights;

  final List<QueueTypeModel> queueTypes;

  QueueTypesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.ownerUsername,
    required this.locationName,
    required this.hasRights,
    required this.queueTypes,
  });

  @override
  QueueTypesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? ownerUsername,
    String? locationName,
    List<QueueTypeModel>? queueTypes,
    bool? hasRights
  }) => QueueTypesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      queueTypes: queueTypes ?? this.queueTypes
  );
}

@injectable
class QueueTypesCubit extends BaseCubit<QueueTypesLogicState> {
  final LocationInteractor _locationInteractor;

  QueueTypesCubit(
      this._locationInteractor,
      @factoryParam QueueTypesConfig config
  ) : super(
      QueueTypesLogicState(
          config: config,
          ownerUsername: null,
          locationName: '',
          hasRights: false,
          queueTypes: []
      )
  );

  @override
  Future<void> onStart() async {
    await _locationInteractor.getLocation(
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

  void handleCreateQueueTypeResult(CreateQueueTypeResult result) {
    emit(state.copy(queueTypes: state.queueTypes + [result.queueTypeModel]));
  }

  void handleDeleteQueueTypeResult(DeleteQueueTypeResult result) {
    emit(
        state.copy(
            queueTypes: state.queueTypes
              ..removeWhere((element) => element.id == result.id)
        )
    );
  }

  Future<void> share(String notificationText) async {
    String username = state.ownerUsername!;
    int locationId = state.config.locationId;
    await Clipboard.setData(
        ClipboardData(
            text: '${ServerApi.clientUrl}/$username/locations/$locationId/queueTypes'
        )
    );
    showSnackBar(notificationText);
  }

  Future<void> downloadQrCode() async {
    String username = state.ownerUsername!;
    int locationId = state.config.locationId;
    String url = '${ServerApi.clientUrl}/$username/locations/$locationId/queueTypes';

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
    await _locationInteractor.getQueueTypesInLocation(
        state.config.locationId
    )
      ..onSuccess((result) {
        emit(state.copy(queueTypes: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}

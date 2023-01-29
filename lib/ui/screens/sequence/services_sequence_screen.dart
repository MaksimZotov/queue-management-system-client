import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/location/services_sequence_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/queue/create_queue_dialog.dart';
import 'package:queue_management_system_client/ui/screens/sequence/create_services_sequence_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/queue_item_widget.dart';
import 'package:queue_management_system_client/ui/widgets/services_sequence_item_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import 'delete_services_sequence_dialog.dart';

class ServicesSequenceWidget extends BaseWidget<ServicesSequenceConfig> {

  const ServicesSequenceWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<ServicesSequenceWidget> createState() => _ServicesSequenceState();
}

class _ServicesSequenceState extends BaseState<
    ServicesSequenceWidget,
    ServicesSequenceLogicState,
    ServicesSequenceCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      ServicesSequenceLogicState state,
      ServicesSequenceWidget widget
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
        return ServicesSequenceItemWidget(
          servicesSequence: state.servicesSequencesModel[index],
          onDelete: (location) => showDialog(
              context: context,
              builder: (context) => DeleteServicesSequenceWidget(
                  config: DeleteServicesSequenceConfig(
                      locationId: location.id,
                      servicesSequenceId: state.servicesSequencesModel[index].id
                  )
              )
          ).then((result) {
            if (result is DeleteServicesSequenceResult) {
              getCubitInstance(context).handleDeleteServicesSequenceResult(result);
            }
          }
          ),
        );
      },
      itemCount: state.servicesSequencesModel.length,
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
        if (result is CreateServicesSequenceResult) {
          getCubitInstance(context).handleCreateServicesSequenceResult(result);
        }
      }),
      child: const Icon(Icons.add),
    )
        : null,
  );

  @override
  ServicesSequenceCubit getCubit() => statesAssembler.getServicesSequenceCubit(widget.config);
}

class ServicesSequenceLogicState extends BaseLogicState {

  final ServicesSequenceConfig config;

  final String? ownerUsername;
  final String locationName;
  final bool hasRights;

  final List<ServicesSequenceModel> servicesSequencesModel;

  ServicesSequenceLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.ownerUsername,
    required this.locationName,
    required this.hasRights,
    required this.servicesSequencesModel,
  });

  @override
  ServicesSequenceLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? ownerUsername,
    String? locationName,
    List<ServicesSequenceModel>? servicesSequencesModel,
    bool? hasRights
  }) => ServicesSequenceLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      servicesSequencesModel: servicesSequencesModel ?? this.servicesSequencesModel
  );
}

@injectable
class ServicesSequenceCubit extends BaseCubit<ServicesSequenceLogicState> {
  final LocationInteractor _locationInteractor;

  ServicesSequenceCubit(
      this._locationInteractor,
      @factoryParam ServicesSequenceConfig config
  ) : super(
      ServicesSequenceLogicState(
          config: config,
          ownerUsername: null,
          locationName: '',
          hasRights: false,
          servicesSequencesModel: []
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

  void handleCreateServicesSequenceResult(CreateServicesSequenceResult result) {
    emit(state.copy(servicesSequencesModel: state.servicesSequencesModel + [result.servicesSequenceModel]));
  }

  void handleDeleteServicesSequenceResult(DeleteServicesSequenceResult result) {
    emit(
        state.copy(
            servicesSequencesModel: state.servicesSequencesModel
              ..removeWhere((element) => element.id == result.servicesSequenceId)
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
    await _locationInteractor.getServicesSequencesInLocation(
        state.config.locationId
    )
      ..onSuccess((result) {
        emit(state.copy(servicesSequencesModel: result.data.results));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}

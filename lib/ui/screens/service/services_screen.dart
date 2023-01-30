import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/service_model.dart';
import '../../models.service/service_wrapper.dart';
import '../../router/routes_config.dart';
import '../../widgets/service_item_widget.dart';
import 'create_service_dialog.dart';
import 'delete_service_dialog.dart';

class ServicesWidget extends BaseWidget<ServicesConfig> {

  const ServicesWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<ServicesWidget> createState() => _ServicesState();
}

class _ServicesState extends BaseState<
    ServicesWidget,
    ServicesLogicState,
    ServicesCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      ServicesLogicState state,
      ServicesWidget widget
      ) => Scaffold(
    appBar: AppBar(
      title: Text(
          state.locationName.isEmpty
              ? ''
              : getLocalizations(context).servicesInLocationPattern(state.locationName)
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
        return ServiceItemWidget(
          serviceWrapper: state.services[index],
          onDelete: (serviceWrapper) => showDialog(
              context: context,
              builder: (context) => DeleteServiceWidget(
                  config: DeleteServiceConfig(
                      locationId: state.config.locationId,
                      serviceId: serviceWrapper.service.id
                  )
              )
          ).then((result) {
            if (result is DeleteServiceResult) {
              getCubitInstance(context).handleDeleteServiceResult(result);
            }
          }
          ),
        );
      },
      itemCount: state.services.length,
    ),
    floatingActionButton: state.hasRights
        ? FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => CreateServiceWidget(
                  config: CreateServiceConfig(
                      locationId: state.config.locationId
                  )
              )
          ).then((result) {
            if (result is CreateServiceResult) {
              getCubitInstance(context).handleCreateServiceResult(result);
            }
          }),
          child: const Icon(Icons.add),
        )
        : null,
  );

  @override
  ServicesCubit getCubit() => statesAssembler.getServicesCubit(widget.config);
}

class ServicesLogicState extends BaseLogicState {

  final ServicesConfig config;

  final String? ownerUsername;
  final String locationName;
  final bool hasRights;

  final List<ServiceWrapper> services;

  ServicesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.ownerUsername,
    required this.locationName,
    required this.hasRights,
    required this.services,
  });

  @override
  ServicesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? ownerUsername,
    String? locationName,
    List<ServiceWrapper>? services,
    bool? hasRights
  }) => ServicesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      services: services ?? this.services
  );
}

@injectable
class ServicesCubit extends BaseCubit<ServicesLogicState> {
  final LocationInteractor _locationInteractor;

  ServicesCubit(
      this._locationInteractor,
      @factoryParam ServicesConfig config
  ) : super(
      ServicesLogicState(
          config: config,
          ownerUsername: null,
          locationName: '',
          hasRights: false,
          services: []
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

  void handleCreateServiceResult(CreateServiceResult result) {
    emit(state.copy(services: state.services + [ServiceWrapper(service: result.serviceModel)]));
  }

  void handleDeleteServiceResult(DeleteServiceResult result) {
    emit(
        state.copy(
            services: state.services
              ..removeWhere((serviceWrapper) => serviceWrapper.service.id == result.serviceId)
        )
    );
  }

  Future<void> share(String notificationText) async {
    String username = state.ownerUsername!;
    int locationId = state.config.locationId;
    await Clipboard.setData(
        ClipboardData(
            text: '${ServerApi.clientUrl}/$username/locations/$locationId/services'
        )
    );
    showSnackBar(notificationText);
  }

  Future<void> downloadQrCode() async {
    String username = state.ownerUsername!;
    int locationId = state.config.locationId;
    String url = '${ServerApi.clientUrl}/$username/locations/$locationId/services';

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
    await _locationInteractor.getServicesInLocation(
        state.config.locationId
    )
      ..onSuccess((result) {
        emit(
            state.copy(
                services: result.data.results
                    .map((service) => ServiceWrapper(service: service))
                    .toList()
            )
        );
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}

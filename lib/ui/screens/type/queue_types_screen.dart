import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/models/location/queue_type_model.dart';
import 'package:queue_management_system_client/ui/models.service/service_wrapper.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/queue_type_item_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/service_model.dart';
import '../../router/routes_config.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/service_item_widget.dart';
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
  void handleEvent(BuildContext context, QueueTypesLogicState state, QueueTypesWidget widget) {
    super.handleEvent(context, state, widget);
    if (state.showCreateQueueTypeDialog) {
      showDialog(
          context: context,
          builder: (context) => CreateQueueTypeWidget(
              config: CreateQueueTypeConfig(
                  locationId: state.config.locationId,
                  serviceIds: state.selectedServices
                      .map((serviceWrapper) => serviceWrapper.service.id)
                      .toList()
              )
          )
      ).then((result) {
        if (result is CreateQueueTypeResult) {
          getCubitInstance(context).handleCreateQueueTypeResult(result);
        }
      });
    }
  }

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
    ),
    body: _getBody(context, state, widget),
    floatingActionButton: state.hasRights && state.queueTypesStateEnum == QueueTypesStateEnum.queueTypesViewing
        ? FloatingActionButton(
          onPressed: getCubitInstance(context).switchToServicesSelecting,
          child: const Icon(Icons.add),
        )
        : null,
  );

  @override
  QueueTypesCubit getCubit() => statesAssembler.getQueueTypesCubit(widget.config);

  Widget _getBody(
      BuildContext context,
      QueueTypesLogicState state,
      QueueTypesWidget widget
  ) {
    switch (state.queueTypesStateEnum) {
      case QueueTypesStateEnum.queueTypesViewing:
        return ListView.builder(
          itemBuilder: (context, index) {
            return QueueTypeItemWidget(
              queueType: state.queueTypes[index],
              onDelete: (queueType) => showDialog(
                  context: context,
                  builder: (context) => DeleteQueueTypeWidget(
                      config: DeleteQueueTypeConfig(
                          locationId: state.config.locationId,
                          queueTypeId: queueType.id
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
        );
      case QueueTypesStateEnum.servicesSelecting:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ServiceItemWidget(
                      serviceWrapper: state.services[index],
                      onTap: getCubitInstance(context).onClickServiceWhenServicesSelecting
                  );
                },
                itemCount: state.services.length,
              ),
            ),
            ButtonWidget(
              text: getLocalizations(context).select,
              onClick: getCubitInstance(context).switchToSelectedServicesViewing,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).switchToQueueTypesViewing,
            )
          ],
        );
      case QueueTypesStateEnum.selectedServicesViewing:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ServiceItemWidget(
                      serviceWrapper: state.selectedServices[index]
                  );
                },
                itemCount: state.selectedServices.length,
              ),
            ),
            ButtonWidget(
              text: getLocalizations(context).confirm,
              onClick: getCubitInstance(context).confirmSelectedServices,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).switchToQueueTypesViewing,
            )
          ],
        );
    }
  }
}

enum QueueTypesStateEnum {
  queueTypesViewing,
  servicesSelecting,
  selectedServicesViewing
}

class QueueTypesLogicState extends BaseLogicState {

  final QueueTypesConfig config;
  
  final QueueTypesStateEnum queueTypesStateEnum;

  final String? ownerUsername;
  final String locationName;
  final bool hasRights;

  final List<QueueTypeModel> queueTypes;
  final List<ServiceWrapper> services;
  final List<ServiceWrapper> selectedServices;

  final bool showCreateQueueTypeDialog;

  QueueTypesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.queueTypesStateEnum,
    required this.ownerUsername,
    required this.locationName,
    required this.hasRights,
    required this.queueTypes,
    required this.services,
    required this.selectedServices,
    required this.showCreateQueueTypeDialog
  });

  @override
  QueueTypesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    QueueTypesStateEnum? queueTypesStateEnum,
    String? ownerUsername,
    String? locationName,
    bool? hasRights,
    List<QueueTypeModel>? queueTypes,
    List<ServiceWrapper>? services,
    List<ServiceWrapper>? selectedServices,
    bool? showCreateQueueTypeDialog,
  }) => QueueTypesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      queueTypesStateEnum: queueTypesStateEnum ?? this.queueTypesStateEnum,
      config: config,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      queueTypes: queueTypes ?? this.queueTypes,
      services: services ?? this.services,
      selectedServices: selectedServices ?? this.selectedServices,
      showCreateQueueTypeDialog: showCreateQueueTypeDialog ?? this.showCreateQueueTypeDialog
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
          queueTypesStateEnum: QueueTypesStateEnum.queueTypesViewing,
          ownerUsername: null,
          locationName: '',
          hasRights: false,
          queueTypes: [],
          services: [],
          selectedServices: [],
          showCreateQueueTypeDialog: false
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
    emit(
        state.copy(
            queueTypesStateEnum: QueueTypesStateEnum.queueTypesViewing,
            services: state.services
                .map((serviceWrapper) => serviceWrapper.copy(selected: false))
                .toList(),
            selectedServices: [],
            queueTypes: state.queueTypes + [result.queueTypeModel]
        )
    );
  }

  void handleDeleteQueueTypeResult(DeleteQueueTypeResult result) {
    emit(
        state.copy(
            queueTypes: state.queueTypes
              ..removeWhere((element) => element.id == result.id)
        )
    );
  }

  void onClickServiceWhenServicesSelecting(ServiceWrapper serviceWrapper) {
    emit(
        state.copy(
            services: state.services
                .map((cur) {
                    if (cur.service.id == serviceWrapper.service.id) {
                      return serviceWrapper.copy(
                          selected: !cur.selected
                      );
                    } else {
                      return cur;
                    }
                 })
                .toList()
        )
    );
  }

  void switchToServicesSelecting() {
    emit(state.copy(queueTypesStateEnum: QueueTypesStateEnum.servicesSelecting));
  }

  void switchToSelectedServicesViewing() {
    emit(
        state.copy(
            queueTypesStateEnum: QueueTypesStateEnum.selectedServicesViewing,
            selectedServices: state.services
                ..removeWhere((serviceWrapper) => !serviceWrapper.selected)
        )
    );
  }

  void switchToQueueTypesViewing() {
    emit(
        state.copy(
          queueTypesStateEnum: QueueTypesStateEnum.queueTypesViewing,
          services: state.services
              .map((serviceWrapper) => serviceWrapper.copy(selected: false))
              .toList(),
          selectedServices: [],
        ));
  }

  void confirmSelectedServices() {
    emit(state.copy(showCreateQueueTypeDialog: true));
    emit(state.copy(showCreateQueueTypeDialog: false));
  }

  Future<void> _load() async {
    await _locationInteractor.getQueueTypesInLocation(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(state.copy(queueTypes: result.data.results));
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
      })
      ..onError((result) {
        showError(result);
      });
  }
}

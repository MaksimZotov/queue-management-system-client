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
import '../../../domain/models/location/services_sequence_model.dart';
import '../../router/routes_config.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/service_item_widget.dart';
import '../../widgets/services_sequence_item_widget.dart';
import 'create_services_sequence_dialog.dart';
import 'delete_services_sequence_dialog.dart';

class ServicesSequencesWidget extends BaseWidget<ServicesSequencesConfig> {

  const ServicesSequencesWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<ServicesSequencesWidget> createState() => _ServicesSequencesState();
}

class _ServicesSequencesState extends BaseState<
    ServicesSequencesWidget,
    ServicesSequencesLogicState,
    ServicesSequencesCubit
> {

  @override
  void handleEvent(BuildContext context, ServicesSequencesLogicState state, ServicesSequencesWidget widget) {
    super.handleEvent(context, state, widget);
    if (state.showCreateServicesSequenceDialog) {
      showDialog(
          context: context,
          builder: (context) => CreateServicesSequenceWidget(
              config: CreateServicesSequenceConfig(
                  locationId: state.config.locationId,
                  serviceIdsToOrderNumbers: {
                    for (var serviceWrapper in state.selectedServices)
                      (serviceWrapper).service.id : (serviceWrapper).orderNumber
                  }
              )
          )
      ).then((result) {
        if (result is CreateServicesSequenceResult) {
          getCubitInstance(context).handleCreateServicesSequenceResult(result);
        }
      });
    }
  }

  @override
  Widget getWidget(
      BuildContext context,
      ServicesSequencesLogicState state,
      ServicesSequencesWidget widget
      ) => Scaffold(
    appBar: AppBar(
      title: Text(
          state.locationName.isEmpty
              ? ''
              : getLocalizations(context).locationPattern(state.locationName)
      ),
    ),
    body: _getBody(context, state, widget),
    floatingActionButton: state.hasRights && state.servicesSequencesStateEnum == ServicesSequencesStateEnum.servicesSequencesViewing
        ? FloatingActionButton(
      onPressed: getCubitInstance(context).switchToServicesSelecting,
      child: const Icon(Icons.add),
    )
        : null,
  );

  @override
  ServicesSequencesCubit getCubit() => statesAssembler.getServicesSequencesCubit(widget.config);

  Widget _getBody(
      BuildContext context,
      ServicesSequencesLogicState state,
      ServicesSequencesWidget widget
  ) {
    switch (state.servicesSequencesStateEnum) {
      case ServicesSequencesStateEnum.servicesSequencesViewing:
        return ListView.builder(
          itemBuilder: (context, index) {
            return ServicesSequenceItemWidget(
              servicesSequence: state.servicesSequences[index],
              onDelete: (serviceSequence) => showDialog(
                  context: context,
                  builder: (context) => DeleteServicesSequenceWidget(
                      config: DeleteServicesSequenceConfig(
                          locationId: state.config.locationId,
                          servicesSequenceId: serviceSequence.id
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
          itemCount: state.servicesSequences.length,
        );
      case ServicesSequencesStateEnum.servicesSelecting:
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
              onClick: getCubitInstance(context).switchToServicesSequencesViewing,
            )
          ],
        );
      case ServicesSequencesStateEnum.selectedServicesViewing:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) => setState(() {
                  getCubitInstance(context).onReorderSelectedServices(oldIndex, newIndex);
                }),
                children: state.selectedServices
                    .map((serviceWrapper) => Row(
                        key: Key(serviceWrapper.service.id.toString()),
                        children: [
                          Card(
                            color: Colors.blueGrey[300],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${serviceWrapper.orderNumber}:',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: ServiceItemWidget(
                                  serviceWrapper: serviceWrapper,
                                  onTap: getCubitInstance(context).onClickServiceWhenSelectedServicesViewing
                              )
                          )
                        ],
                      )
                    )
                    .toList()
              ),
            ),
            ButtonWidget(
              text: getLocalizations(context).confirm,
              onClick: getCubitInstance(context).confirmSelectedServices,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).switchToServicesSequencesViewing,
            )
          ],
        );
    }
  }
}

enum ServicesSequencesStateEnum {
  servicesSequencesViewing,
  servicesSelecting,
  selectedServicesViewing
}

class ServicesSequencesLogicState extends BaseLogicState {

  final ServicesSequencesConfig config;

  final ServicesSequencesStateEnum servicesSequencesStateEnum;

  final String? ownerUsername;
  final String locationName;
  final bool hasRights;

  final List<ServicesSequenceModel> servicesSequences;
  final List<ServiceWrapper> services;
  final List<ServiceWrapper> selectedServices;

  final bool showCreateServicesSequenceDialog;

  ServicesSequencesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.servicesSequencesStateEnum,
    required this.ownerUsername,
    required this.locationName,
    required this.hasRights,
    required this.servicesSequences,
    required this.services,
    required this.selectedServices,
    required this.showCreateServicesSequenceDialog
  });

  @override
  ServicesSequencesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    ServicesSequencesStateEnum? servicesSequencesStateEnum,
    String? ownerUsername,
    String? locationName,
    bool? hasRights,
    List<ServicesSequenceModel>? servicesSequences,
    List<ServiceWrapper>? services,
    List<ServiceWrapper>? selectedServices,
    bool? showCreateServicesSequenceDialog,
  }) => ServicesSequencesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      servicesSequencesStateEnum: servicesSequencesStateEnum ?? this.servicesSequencesStateEnum,
      config: config,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      servicesSequences: servicesSequences ?? this.servicesSequences,
      services: services ?? this.services,
      selectedServices: selectedServices ?? this.selectedServices,
      showCreateServicesSequenceDialog: showCreateServicesSequenceDialog ?? this.showCreateServicesSequenceDialog
  );
}

@injectable
class ServicesSequencesCubit extends BaseCubit<ServicesSequencesLogicState> {
  final LocationInteractor _locationInteractor;

  ServicesSequencesCubit(
      this._locationInteractor,
      @factoryParam ServicesSequencesConfig config
  ) : super(
      ServicesSequencesLogicState(
          config: config,
          servicesSequencesStateEnum: ServicesSequencesStateEnum.servicesSequencesViewing,
          ownerUsername: null,
          locationName: '',
          hasRights: false,
          servicesSequences: [],
          services: [],
          selectedServices: [],
          showCreateServicesSequenceDialog: false
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
    emit(
        state.copy(
            servicesSequencesStateEnum: ServicesSequencesStateEnum.servicesSequencesViewing,
            services: state.services
                .map((serviceWrapper) => serviceWrapper.copy(selected: false))
                .toList(),
            selectedServices: [],
            servicesSequences: state.servicesSequences + [result.servicesSequenceModel]
        )
    );
  }

  void handleDeleteServicesSequenceResult(DeleteServicesSequenceResult result) {
    emit(
        state.copy(
            servicesSequences: state.servicesSequences
              ..removeWhere((element) => element.id == result.servicesSequenceId)
        )
    );
  }

  void onClickServiceWhenServicesSelecting(ServiceWrapper serviceWrapper) {
    emit(
        state.copy(
            services: state.services.map((cur) {
              if (cur.service.id == serviceWrapper.service.id) {
                return serviceWrapper.copy(
                    selected: !cur.selected
                );
              } else {
                return cur;
              }
            }).toList()
        )
    );
  }

  void onClickServiceWhenSelectedServicesViewing(ServiceWrapper serviceWrapper) {
    List<ServiceWrapper> selectedServices = state.selectedServices;
    int orderNumber = serviceWrapper.orderNumber;
    if (serviceWrapper.selected) {
      selectedServices = selectedServices
          .map((cur) {
            if (cur.orderNumber > orderNumber) {
              return cur.copy(orderNumber: cur.orderNumber + 1);
            }
            return cur;
          })
          .toList();
    } else {
      selectedServices = selectedServices
          .map((cur) {
            return cur;
          })
          .toList();
    }
    selectedServices.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    emit(state.copy(selectedServices: selectedServices));
  }

  void onReorderSelectedServices(int oldIndex, int newIndex) {
    List<ServiceWrapper> selectedServices = state.selectedServices;
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }
    final item = selectedServices.removeAt(oldIndex);
    selectedServices.insert(newIndex, item);

    int i = 0;
    selectedServices = selectedServices
        .map((serviceWrapper) => serviceWrapper.copy(orderNumber: ++i))
        .toList();

    emit(state.copy(selectedServices: selectedServices));
  }

  void switchToServicesSelecting() {
    emit(state.copy(servicesSequencesStateEnum: ServicesSequencesStateEnum.servicesSelecting));
  }

  void switchToSelectedServicesViewing() {
    int i = 0;

    List<ServiceWrapper> selectedServices = state.services
      ..removeWhere((serviceWrapper) => !serviceWrapper.selected);

    selectedServices = selectedServices
        .map((serviceWrapper) => serviceWrapper.copy(selected: false, orderNumber: ++i))
        .toList();

    emit(
        state.copy(
            servicesSequencesStateEnum: ServicesSequencesStateEnum.selectedServicesViewing,
            selectedServices: selectedServices
        )
    );
  }

  void switchToServicesSequencesViewing() {
    emit(
        state.copy(
          servicesSequencesStateEnum: ServicesSequencesStateEnum.servicesSequencesViewing,
          services: state.services
              .map((serviceWrapper) => serviceWrapper.copy(selected: false))
              .toList(),
          selectedServices: [],
        ));
  }

  void confirmSelectedServices() {
    emit(state.copy(showCreateServicesSequenceDialog: true));
    emit(state.copy(showCreateServicesSequenceDialog: false));
  }

  Future<void> _load() async {
    await _locationInteractor.getServicesSequencesInLocation(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(state.copy(servicesSequences: result.data.results));
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

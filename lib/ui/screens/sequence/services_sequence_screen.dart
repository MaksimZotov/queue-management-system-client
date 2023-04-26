import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/enums/kiosk_mode.dart';
import 'package:queue_management_system_client/domain/models/client/change_client_request.dart';
import 'package:queue_management_system_client/domain/models/specialist/specialist_model.dart';
import 'package:queue_management_system_client/ui/models/service/service_wrapper.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/client/add_client_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/specialist_item_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/client_interactor.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/kiosk_interactor.dart';
import '../../../domain/interactors/service_interactor.dart';
import '../../../domain/interactors/services_sequence_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/kiosk/kiosk_state.dart';
import '../../../domain/models/location/location_model.dart';
import '../../../domain/models/service/service_model.dart';
import '../../../domain/models/sequence/services_sequence_model.dart';
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
    appBar: state.kioskState == null || state.kioskState?.kioskMode == KioskMode.all
      ? AppBar(
        title: Text(
            state.locationName.isEmpty
                ? ''
                : getLocalizations(context).servicesSequences
        ),
      )
      : null,
    body: _getBody(context, state, widget),
    floatingActionButton: _checkFloatingActionButton(state)
        ? FloatingActionButton(
          tooltip: getLocalizations(context).createServicesSequence,
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
              onDelete: state.kioskState == null
                  ? (serviceSequence) => showDialog(
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
                    })
                  : null,
              onTap: state.kioskState != null
                  ? (servicesSequence) => showDialog(
                        context: context,
                        builder: (context) => AddClientWidget(
                            config: AddClientConfig(
                                locationId: state.config.locationId,
                                servicesSequenceId: servicesSequence.id
                            )
                        )
                    ).then((result) {
                      if (result is AddClientResult) {
                        if (state.kioskState?.kioskMode == KioskMode.all) {
                          Navigator.of(context).pop();
                        }
                      }
                    })
                  : null
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
            Container(height: 2, color: Colors.grey),
            const SizedBox(height: Dimens.contentMargin),
            ButtonWidget(
              text: getLocalizations(context).select,
              onClick: getCubitInstance(context).switchToSelectedServicesViewing,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).switchToServicesSequencesViewing,
            ),
            const SizedBox(height: Dimens.contentMargin)
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
            Container(height: 2, color: Colors.grey),
            const SizedBox(height: Dimens.contentMargin),
            ButtonWidget(
              text: getLocalizations(context).confirm,
              onClick: getCubitInstance(context).confirmSelectedServices,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).switchToServicesSequencesViewing,
            ),
            const SizedBox(height: Dimens.contentMargin)
          ],
        );
      case ServicesSequencesStateEnum.selectedServicesViewingClientChanging:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) => setState(() {
                    getCubitInstance(context).onReorderSelectedServices(oldIndex, newIndex);
                  }),
                  children: state.selectedServices.map((serviceWrapper) => Row(
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
                  )).toList()
              ),
            ),
            Container(height: 2, color: Colors.grey),
            const SizedBox(height: Dimens.contentMargin),
            ButtonWidget(
              text: getLocalizations(context).assign,
              onClick: getCubitInstance(context).changeClient,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: Navigator.of(context).pop
            ),
            const SizedBox(height: Dimens.contentMargin)
          ],
        );
    }
  }

  bool _checkFloatingActionButton(ServicesSequencesLogicState state) =>
      state.hasRights && state.servicesSequencesStateEnum == ServicesSequencesStateEnum.servicesSequencesViewing && state.kioskState == null;
}

enum ServicesSequencesStateEnum {
  servicesSequencesViewing,
  servicesSelecting,
  selectedServicesViewing,
  selectedServicesViewingClientChanging
}

class ServicesSequencesLogicState extends BaseLogicState {

  final ServicesSequencesConfig config;

  final ServicesSequencesStateEnum servicesSequencesStateEnum;

  final String? ownerEmail;
  final String locationName;
  final bool hasRights;

  final List<ServicesSequenceModel> servicesSequences;
  final List<ServiceWrapper> services;
  final List<ServiceWrapper> selectedServices;

  final bool showCreateServicesSequenceDialog;

  KioskState? get kioskState  {
    for (KioskMode mode in KioskMode.values) {
      if (mode.name == config.kioskMode) {
        return KioskState(
            kioskMode: mode,
            multipleSelect: config.multipleSelect ?? false
        );
      }
    }
    return null;
  }

  ServicesSequencesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.servicesSequencesStateEnum,
    required this.ownerEmail,
    required this.locationName,
    required this.hasRights,
    required this.servicesSequences,
    required this.services,
    required this.selectedServices,
    required this.showCreateServicesSequenceDialog,
  });

  @override
  ServicesSequencesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    ServicesSequencesStateEnum? servicesSequencesStateEnum,
    String? ownerEmail,
    String? locationName,
    bool? hasRights,
    List<ServicesSequenceModel>? servicesSequences,
    List<ServiceWrapper>? services,
    List<ServiceWrapper>? selectedServices,
    bool? showCreateServicesSequenceDialog
  }) => ServicesSequencesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      servicesSequencesStateEnum: servicesSequencesStateEnum ?? this.servicesSequencesStateEnum,
      config: config,
      ownerEmail: ownerEmail ?? this.ownerEmail,
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
  final ClientInteractor _clientInteractor;
  final ServiceInteractor _serviceInteractor;
  final ServicesSequenceInteractor _servicesSequenceInteractor;

  ServicesSequencesCubit(
      this._locationInteractor,
      this._clientInteractor,
      this._serviceInteractor,
      this._servicesSequenceInteractor,
      @factoryParam ServicesSequencesConfig config
  ) : super(
      ServicesSequencesLogicState(
          config: config,
          servicesSequencesStateEnum: ServicesSequencesStateEnum.servicesSequencesViewing,
          ownerEmail: null,
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
    if (state.config.queueId != null && state.config.clientId != null) {
      emit(
          state.copy(
              servicesSequencesStateEnum: ServicesSequencesStateEnum.servicesSelecting
          )
      );
    }
    await _locationInteractor.getLocation(state.config.locationId)
      ..onSuccess((result) async {
        LocationModel location = result.data;
        emit(
            state.copy(
                ownerEmail: location.ownerEmail,
                locationName: location.name,
                hasRights: location.isOwner ? true : location.rightsStatus != null
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
            servicesSequences: List.from(state.servicesSequences)
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
    int order = serviceWrapper.orderNumber;

    ServiceWrapper Function(ServiceWrapper serviceWrapper) mapServices;

    if (!serviceWrapper.selected) {
      bool hasPrev = false;
      bool hasNext = false;

      for (ServiceWrapper item in selectedServices) {
        if (item.orderNumber == serviceWrapper.orderNumber - 1 && item.selected) {
          hasPrev = true;
        }
        if (item.orderNumber == serviceWrapper.orderNumber + 1 && item.selected) {
          hasNext = true;
        }
      }

      if (hasPrev && hasNext) {
        mapServices = (cur) {
          if ([order - 1, order, order + 1].contains(cur.orderNumber)) {
            return cur.copy(selected: true, orderNumber: order - 1);
          }
          if (cur.orderNumber >= order) {
            return cur.copy(orderNumber: cur.orderNumber - 1);
          }
          return cur;
        };
      } else if (hasPrev) {
        mapServices = (cur) {
          if ([order - 1, order].contains(cur.orderNumber)) {
            return cur.copy(selected: true, orderNumber: order - 1);
          }
          if (cur.orderNumber >= order) {
            return cur.copy(orderNumber: cur.orderNumber - 1);
          }
          return cur;
        };
      } else if (hasNext) {
        mapServices = (cur) {
          if ([order, order + 1].contains(cur.orderNumber)) {
            return cur.copy(selected: true, orderNumber: order);
          }
          if (cur.orderNumber >= order) {
            return cur.copy(orderNumber: cur.orderNumber - 1);
          }
          return cur;
        };
      } else {
        mapServices = (cur) {
          if (cur.service.id == serviceWrapper.service.id) {
            return cur.copy(selected: true);
          }
          return cur;
        };
      }
    } else {
      bool hasTheSameOrder = false;

      for (ServiceWrapper item in selectedServices) {
        if (serviceWrapper.orderNumber == item.orderNumber && item.service.id != serviceWrapper.service.id) {
          hasTheSameOrder = true;
          break;
        }
      }

      if (hasTheSameOrder) {
        mapServices = (cur) {
          if (cur.orderNumber > serviceWrapper.orderNumber) {
            return cur.copy(
                orderNumber: cur.orderNumber + 1
            );
          }
          if (cur.service.id == serviceWrapper.service.id) {
            return cur.copy(
                selected: false,
                orderNumber: cur.orderNumber + 1
            );
          }
          return cur;
        };
      } else {
        mapServices = (cur) {
          if (cur.service.id == serviceWrapper.service.id) {
            return cur.copy(selected: false);
          }
          return cur;
        };
      }
    }

    selectedServices = selectedServices.map(mapServices).toList();
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
        .map((serviceWrapper) => serviceWrapper.copy(selected: false, orderNumber: ++i))
        .toList();

    emit(state.copy(selectedServices: selectedServices));
  }

  void switchToServicesSelecting() {
    emit(state.copy(servicesSequencesStateEnum: ServicesSequencesStateEnum.servicesSelecting));
  }

  void switchToSelectedServicesViewing() {
    ServicesSequencesStateEnum nextState;
    if (state.config.clientId != null && state.config.queueId != null) {
      nextState = ServicesSequencesStateEnum.selectedServicesViewingClientChanging;
    } else {
      nextState = ServicesSequencesStateEnum.selectedServicesViewing;
    }

    int i = 0;

    List<ServiceWrapper> selectedServices = List.from(state.services)
      ..removeWhere((serviceWrapper) => !serviceWrapper.selected);

    selectedServices = selectedServices
        .map((serviceWrapper) => serviceWrapper.copy(selected: false, orderNumber: ++i))
        .toList();

    emit(
        state.copy(
            servicesSequencesStateEnum: nextState,
            selectedServices: selectedServices
        )
    );
  }

  void switchToServicesSequencesViewing() {
    if (state.config.clientId != null && state.config.queueId != null) {
      navigate(
          QueueConfig(
              accountId: state.config.accountId,
              locationId: state.config.locationId,
              queueId: state.config.queueId!,
              updateQueue: !state.config.updateQueue
          )
      );
      return;
    }

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

  Future<void> changeClient() async {
    int? clientId = state.config.clientId;
    if (clientId == null) {
      return;
    }
    await _clientInteractor.changeClientInLocation(
        state.config.locationId,
        clientId,
        ChangeClientRequest(
            serviceIdsToOrderNumbers: {
              for (var serviceWrapper in state.selectedServices)
                (serviceWrapper).service.id : (serviceWrapper).orderNumber
            }
        )
    )
      ..onSuccess((result) {
        navigate(
            QueueConfig(
              accountId: state.config.accountId,
              locationId: state.config.locationId,
              queueId: state.config.queueId!,
              updateQueue: state.config.updateQueue
            )
        );
      })
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> _load() async {
    await _servicesSequenceInteractor.getServicesSequencesInLocation(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(state.copy(servicesSequences: result.data.results));
        await _serviceInteractor.getServicesInLocation(
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

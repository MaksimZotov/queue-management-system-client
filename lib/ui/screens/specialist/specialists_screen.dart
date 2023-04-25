import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/specialist_interactor.dart';
import 'package:queue_management_system_client/domain/models/location/specialist_model.dart';
import 'package:queue_management_system_client/ui/models/service/service_wrapper.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/specialist_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/enums/kiosk_mode.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/service_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/kiosk/kiosk_state.dart';
import '../../../domain/models/location/location_model.dart';
import '../../router/routes_config.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/service_item_widget.dart';
import '../client/add_client_dialog.dart';
import 'create_specialist_dialog.dart';
import 'delete_specialist_dialog.dart';

class SpecialistsWidget extends BaseWidget<SpecialistsConfig> {

  const SpecialistsWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<SpecialistsWidget> createState() => _SpecialistsState();
}

class _SpecialistsState extends BaseState<
    SpecialistsWidget,
    SpecialistsLogicState,
    SpecialistsCubit
> {

  @override
  void handleEvent(BuildContext context, SpecialistsLogicState state, SpecialistsWidget widget) {
    super.handleEvent(context, state, widget);
    if (state.showCreateSpecialistDialog) {
      showDialog(
          context: context,
          builder: (context) => CreateSpecialistWidget(
              config: CreateSpecialistConfig(
                  locationId: state.config.locationId,
                  serviceIds: state.selectedServices
                      .map((serviceWrapper) => serviceWrapper.service.id)
                      .toList()
              )
          )
      ).then((result) {
        if (result is CreateSpecialistResult) {
          getCubitInstance(context).handleCreateSpecialistResult(result);
        }
      });
    }
  }

  @override
  Widget getWidget(
      BuildContext context,
      SpecialistsLogicState state,
      SpecialistsWidget widget
  ) => WillPopScope(
    onWillPop: () async {
      if (state.specialistsStateEnum == SpecialistsStateEnum.specialistsViewing) {
        return true;
      }
      getCubitInstance(context).switchToSpecialistsViewing();
      return false;
    },
    child: Scaffold(
      appBar: state.kioskState == null || state.kioskState?.kioskMode == KioskMode.all
          ? AppBar(
              title: Text(_getTitleText(context, state))
          )
          : null,
      body: _getBody(context, state, widget),
      floatingActionButton: _checkFloatingActionButton(state)
          ? FloatingActionButton(
            tooltip: getLocalizations(context).createSpecialist,
            onPressed: getCubitInstance(context).switchToServicesSelecting,
            child: const Icon(Icons.add),
          )
          : null,
    )
  );

  @override
  SpecialistsCubit getCubit() =>
      statesAssembler.getSpecialistsCubit(widget.config);

  Widget _getBody(
      BuildContext context,
      SpecialistsLogicState state,
      SpecialistsWidget widget
  ) {
    switch (state.specialistsStateEnum) {
      case SpecialistsStateEnum.specialistsViewing:
        return ListView.builder(
          itemBuilder: (context, index) {
            return SpecialistItemWidget(
              specialist: state.specialists[index],
              onDelete: state.kioskState == null
                ? (specialist) => showDialog(
                      context: context,
                      builder: (context) => DeleteSpecialistWidget(
                          config: DeleteSpecialistConfig(
                              locationId: state.config.locationId,
                              specialistId: specialist.id
                          )
                      )
                  ).then((result) {
                    if (result is DeleteSpecialistResult) {
                      getCubitInstance(context).handleDeleteSpecialistResult(result);
                    }
                  })
                : null,
              onTap: getCubitInstance(context).switchToServicesInSpecialist
            );
          },
          itemCount: state.specialists.length,
        );
      case SpecialistsStateEnum.servicesSelecting:
        if (state.selectedServices.isEmpty) {
          return ListView.builder(
            itemBuilder: (context, index) {
              return ServiceItemWidget(
                  serviceWrapper: state.services[index],
                  onTap: state.kioskState != null
                    ? (serviceWrapper) => {
                      if (state.kioskState?.multipleSelect == false) {
                        _showAddClientDialog(context, state, [serviceWrapper])
                      } else {
                        getCubitInstance(context).onClickServiceWhenServicesSelecting(serviceWrapper)
                      }
                    }
                    : null
              );
            },
            itemCount: state.services.length,
          );
        } else {
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
                  text: state.kioskState == null
                      ? getLocalizations(context).select
                      : getLocalizations(context).connect,
                  onClick: state.kioskState == null
                      ? getCubitInstance(context).switchToSelectedServicesViewing
                      : () => _showAddClientDialog(context, state, state.selectedServices)
              ),
              ButtonWidget(
                text: getLocalizations(context).cancel,
                onClick: getCubitInstance(context).switchToSpecialistsViewing,
              ),
              const SizedBox(height: Dimens.contentMargin)
            ],
          );
        }
      case SpecialistsStateEnum.selectedServicesViewing:
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
            Container(height: 2, color: Colors.grey),
            const SizedBox(height: Dimens.contentMargin),
            ButtonWidget(
              text: getLocalizations(context).confirm,
              onClick: getCubitInstance(context).confirmSelectedServices,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).switchToSpecialistsViewing,
            ),
            const SizedBox(height: Dimens.contentMargin)
          ],
        );
    }
  }

  bool _checkFloatingActionButton(SpecialistsLogicState state) =>
      state.hasRights && state.specialistsStateEnum == SpecialistsStateEnum.specialistsViewing && state.kioskState == null;

  String _getTitleText(BuildContext context, SpecialistsLogicState state) {
    if (state.specialistsStateEnum == SpecialistsStateEnum.specialistsViewing) {
      if (state.locationName.isEmpty) {
        return '';
      }
      return getLocalizations(context).specialists;
    }
    return getLocalizations(context).services;
  }

  void _showAddClientDialog(
      BuildContext context,
      SpecialistsLogicState state,
      List<ServiceWrapper> serviceWrappers
  ) => showDialog(
      context: context,
      builder: (context) => AddClientWidget(
          config: AddClientConfig(
              locationId: state.config.locationId,
              serviceIds: serviceWrappers
                  .map((serviceWrapper) => serviceWrapper.service.id)
                  .toList()
          )
      )
  ).then((result) {
    if (result is AddClientResult) {
      if (state.kioskState?.kioskMode == KioskMode.all) {
        Navigator.of(context).pop();
      } else {
        getCubitInstance(context).switchToSpecialistsViewing();
      }
    }
  });
}

enum SpecialistsStateEnum {
  specialistsViewing,
  servicesSelecting,
  selectedServicesViewing
}

class SpecialistsLogicState extends BaseLogicState {

  final SpecialistsConfig config;
  
  final SpecialistsStateEnum specialistsStateEnum;

  final String? ownerEmail;
  final String locationName;
  final bool hasRights;

  final List<SpecialistModel> specialists;
  final List<ServiceWrapper> services;

  final bool showCreateSpecialistDialog;

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

  List<ServiceWrapper> get selectedServices {
    return List.from(services)..removeWhere((serviceWrapper) => !serviceWrapper.selected);
  }

  SpecialistsLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.specialistsStateEnum,
    required this.ownerEmail,
    required this.locationName,
    required this.hasRights,
    required this.specialists,
    required this.services,
    required this.showCreateSpecialistDialog
  });

  @override
  SpecialistsLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    SpecialistsStateEnum? specialistsStateEnum,
    String? ownerEmail,
    String? locationName,
    bool? hasRights,
    List<SpecialistModel>? specialists,
    List<ServiceWrapper>? services,
    bool? showCreateSpecialistDialog,
  }) => SpecialistsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      specialistsStateEnum: specialistsStateEnum ?? this.specialistsStateEnum,
      config: config,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      specialists: specialists ?? this.specialists,
      services: services ?? this.services,
      showCreateSpecialistDialog: showCreateSpecialistDialog ?? this.showCreateSpecialistDialog
  );
}

@injectable
class SpecialistsCubit extends BaseCubit<SpecialistsLogicState> {
  final LocationInteractor _locationInteractor;
  final SpecialistInteractor _specialistInteractor;
  final ServiceInteractor _serviceInteractor;

  SpecialistsCubit(
      this._locationInteractor,
      this._specialistInteractor,
      this._serviceInteractor,
      @factoryParam SpecialistsConfig config
  ) : super(
      SpecialistsLogicState(
          config: config,
          specialistsStateEnum: SpecialistsStateEnum.specialistsViewing,
          ownerEmail: null,
          locationName: '',
          hasRights: false,
          specialists: [],
          services: [],
          showCreateSpecialistDialog: false
      )
  );

  @override
  Future<void> onStart() async {
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

  void handleCreateSpecialistResult(CreateSpecialistResult result) {
    emit(
        state.copy(
            specialistsStateEnum: SpecialistsStateEnum.specialistsViewing,
            services: state.services
                .map((serviceWrapper) => serviceWrapper.copy(selected: false))
                .toList(),
            specialists: state.specialists + [result.specialistModel]
        )
    );
  }

  void handleDeleteSpecialistResult(DeleteSpecialistResult result) {
    emit(
        state.copy(
            specialists: List.from(state.specialists)
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
    emit(state.copy(specialistsStateEnum: SpecialistsStateEnum.servicesSelecting));
  }

  void switchToSelectedServicesViewing() {
    emit(
        state.copy(
            specialistsStateEnum: SpecialistsStateEnum.selectedServicesViewing
        )
    );
  }

  void switchToSpecialistsViewing() {
    emit(
        state.copy(
          specialistsStateEnum: SpecialistsStateEnum.specialistsViewing,
          services: state.services
              .map((serviceWrapper) => serviceWrapper.copy(selected: false))
              .toList()
        ));
  }

  void confirmSelectedServices() {
    emit(state.copy(showCreateSpecialistDialog: true));
    emit(state.copy(showCreateSpecialistDialog: false));
  }

  Future<void> switchToServicesInSpecialist(SpecialistModel? specialistModel) async {
    if (specialistModel == null) {
      return;
    }
    showLoad();
    await _serviceInteractor.getServicesInSpecialist(specialistModel.id)
      ..onSuccess((result) {
        hideLoad();
        emit(
            state.copy(
                specialistsStateEnum: SpecialistsStateEnum.servicesSelecting,
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

  Future<void> _load() async {
    await _specialistInteractor.getSpecialistsInLocation(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(state.copy(specialists: result.data.results));
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

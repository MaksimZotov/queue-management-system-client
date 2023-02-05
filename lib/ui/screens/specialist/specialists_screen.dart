import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/models/location/specialist_model.dart';
import 'package:queue_management_system_client/ui/models/service/service_wrapper.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/queue_type_item_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/kiosk_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/kiosk/kiosk_state.dart';
import '../../../domain/models/location/location_model.dart';
import '../../router/routes_config.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/service_item_widget.dart';
import 'create_queue_type_dialog.dart';
import 'delete_queue_type_dialog.dart';

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
  ) => Scaffold(
    appBar: state.kioskState == null
      ? AppBar(
        title: Text(
            state.locationName.isEmpty
                ? ''
                : getLocalizations(context).specialistsInLocationPattern(state.locationName)
        ),
      )
      : null,
    body: _getBody(context, state, widget),
    floatingActionButton: state.hasRights && state.specialistsStateEnum == SpecialistsStateEnum.specialistsViewing
        ? FloatingActionButton(
          onPressed: getCubitInstance(context).switchToServicesSelecting,
          child: const Icon(Icons.add),
        )
        : null,
  );

  @override
  SpecialistsCubit getCubit() => statesAssembler.getSpecialistsCubit(widget.config);

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
            );
          },
          itemCount: state.specialists.length,
        );
      case SpecialistsStateEnum.servicesSelecting:
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
              onClick: getCubitInstance(context).switchToSpecialistsViewing,
            )
          ],
        );
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
            ButtonWidget(
              text: getLocalizations(context).confirm,
              onClick: getCubitInstance(context).confirmSelectedServices,
            ),
            ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).switchToSpecialistsViewing,
            )
          ],
        );
    }
  }
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
  final List<ServiceWrapper> selectedServices;

  final bool showCreateSpecialistDialog;

  final KioskState? kioskState;

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
    required this.selectedServices,
    required this.showCreateSpecialistDialog,
    required this.kioskState
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
    List<ServiceWrapper>? selectedServices,
    bool? showCreateSpecialistDialog,
    KioskState? kioskState
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
      selectedServices: selectedServices ?? this.selectedServices,
      showCreateSpecialistDialog: showCreateSpecialistDialog ?? this.showCreateSpecialistDialog,
      kioskState: kioskState ?? this.kioskState
  );
}

@injectable
class SpecialistsCubit extends BaseCubit<SpecialistsLogicState> {
  final LocationInteractor _locationInteractor;
  final KioskInteractor _terminalInteractor;

  SpecialistsCubit(
      this._locationInteractor,
      this._terminalInteractor,
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
          selectedServices: [],
          showCreateSpecialistDialog: false,
          kioskState: null
      )
  );

  @override
  Future<void> onStart() async {
    emit(state.copy(kioskState: await _terminalInteractor.getKioskState()));
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
            selectedServices: [],
            specialists: state.specialists + [result.specialistModel]
        )
    );
  }

  void handleDeleteSpecialistResult(DeleteSpecialistResult result) {
    emit(
        state.copy(
            specialists: state.specialists
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
            specialistsStateEnum: SpecialistsStateEnum.selectedServicesViewing,
            selectedServices: state.services
                ..removeWhere((serviceWrapper) => !serviceWrapper.selected)
        )
    );
  }

  void switchToSpecialistsViewing() {
    emit(
        state.copy(
          specialistsStateEnum: SpecialistsStateEnum.specialistsViewing,
          services: state.services
              .map((serviceWrapper) => serviceWrapper.copy(selected: false))
              .toList(),
          selectedServices: [],
        ));
  }

  void confirmSelectedServices() {
    emit(state.copy(showCreateSpecialistDialog: true));
    emit(state.copy(showCreateSpecialistDialog: false));
  }

  Future<void> _load() async {
    await _locationInteractor.getSpecialistsInLocation(
        state.config.locationId
    )
      ..onSuccess((result) async {
        emit(state.copy(specialists: result.data.results));
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

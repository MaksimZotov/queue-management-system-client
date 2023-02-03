import 'dart:developer';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/enums/terminal_mode.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/terminal_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/service_model.dart';
import '../../../domain/models/terminal/terminal_state.dart';
import '../../models/service/service_wrapper.dart';
import '../../router/routes_config.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/service_item_widget.dart';
import '../client/add_client_dialog.dart';
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
    appBar: state.terminalState == null
      ? AppBar(
        title: Text(
            state.locationName.isEmpty
                ? ''
                : getLocalizations(context).servicesInLocationPattern(state.locationName)
        ),
      )
      : null,
    body: _getBody(context, state, widget),
    floatingActionButton: state.hasRights && state.terminalState == null
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

  Widget _getBody(
      BuildContext context,
      ServicesLogicState state,
      ServicesWidget widget
  ) {
    if (state.terminalState == null) {
      return ListView.builder(
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
                })
            );
          },
          itemCount: state.services.length,
      );
    }
    if (state.terminalState?.multipleSelect == false) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return ServiceItemWidget(
              serviceWrapper: state.services[index],
              onTap: (serviceWrapper) => showDialog(
                  context: context,
                  builder: (context) => AddClientWidget(
                      config: AddClientConfig(
                          locationId: state.config.locationId,
                          serviceIds: [serviceWrapper.service.id]
                      )
                  )
              ).then((result) {
                if (result is AddClientResult) {
                  if (state.terminalState?.terminalMode == TerminalMode.all) {
                    Navigator.of(context).pop();
                  }
                }
              })
          );
        },
        itemCount: state.services.length,
      );
    }
    if (state.terminalState?.multipleSelect == true && state.selectedServices.isEmpty) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return ServiceItemWidget(
              serviceWrapper: state.services[index],
              onTap: getCubitInstance(context).onClickServiceWhenServicesSelecting
          );
        },
        itemCount: state.services.length,
      );
    }
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
          text: getLocalizations(context).connect,
          onClick: () => showDialog(
              context: context,
              builder: (context) => AddClientWidget(
                  config: AddClientConfig(
                      locationId: state.config.locationId,
                      serviceIds: state.selectedServices
                          .map((serviceWrapper) => serviceWrapper.service.id)
                          .toList()
                  )
              )
          ).then((result) {
            if (result is AddClientResult) {
              if (state.terminalState?.terminalMode == TerminalMode.all) {
                Navigator.of(context).pop();
              }
            }
          })
        ),
        ButtonWidget(
          text: getLocalizations(context).cancel,
          onClick: getCubitInstance(context).clearSelect,
        )
      ],
    );
  }
}

class ServicesLogicState extends BaseLogicState {

  final ServicesConfig config;

  final String? ownerUsername;
  final String locationName;
  final bool hasRights;

  final List<ServiceWrapper> services;

  final TerminalState? terminalState;

  List<ServiceWrapper> get selectedServices {
    return List.from(services)..removeWhere((serviceWrapper) => !serviceWrapper.selected);
  }

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
    required this.terminalState
  });

  @override
  ServicesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? ownerUsername,
    String? locationName,
    bool? hasRights,
    List<ServiceWrapper>? services,
    List<ServiceWrapper>? selectedServices,
    TerminalState? terminalState
  }) => ServicesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      services: services ?? this.services,
      terminalState: terminalState ?? this.terminalState
  );
}

@injectable
class ServicesCubit extends BaseCubit<ServicesLogicState> {
  final LocationInteractor _locationInteractor;
  final TerminalInteractor _terminalInteractor;

  ServicesCubit(
      this._locationInteractor,
      this._terminalInteractor,
      @factoryParam ServicesConfig config
  ) : super(
      ServicesLogicState(
          config: config,
          ownerUsername: null,
          locationName: '',
          hasRights: false,
          services: [],
          terminalState: null
      )
  );

  @override
  Future<void> onStart() async {
    emit(state.copy(terminalState: await _terminalInteractor.getTerminalState()));
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

  void clearSelect() {
    emit(
        state.copy(
            services: state.services
                .map((cur) => cur.copy(selected: false))
                .toList()
        )
    );
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

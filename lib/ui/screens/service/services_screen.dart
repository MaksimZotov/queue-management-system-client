import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/enums/kiosk_mode.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/service_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/kiosk/kiosk_state.dart';
import '../../../domain/models/location/location_model.dart';
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
    appBar: state.kioskState == null || state.kioskState?.kioskMode == KioskMode.all
      ? AppBar(
        title: Text(
            state.locationName.isEmpty
                ? ''
                : getLocalizations(context).services
        ),
      )
      : null,
    body: _getBody(context, state, widget),
    floatingActionButton: state.hasRights && state.kioskState == null
        ? FloatingActionButton(
            tooltip: getLocalizations(context).createService,
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
    if (state.kioskState == null) {
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
    if (state.kioskState?.multipleSelect == false) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return ServiceItemWidget(
              serviceWrapper: state.services[index],
              onTap: (serviceWrapper) => _showAddClientDialog(context, state, [serviceWrapper])
          );
        },
        itemCount: state.services.length,
      );
    }
    if (state.kioskState?.multipleSelect == true && state.selectedServices.isEmpty) {
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
        Container(height: 2, color: Colors.grey),
        const SizedBox(height: Dimens.contentMargin),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ButtonWidget(
            text: getLocalizations(context).connect,
            onClick: () => _showAddClientDialog(context, state, state.selectedServices)
          )
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ButtonWidget(
              text: getLocalizations(context).cancel,
              onClick: getCubitInstance(context).clearSelect
            )
        ),
        const SizedBox(height: Dimens.contentMargin),
      ],
    );
  }

  void _showAddClientDialog(
      BuildContext context,
      ServicesLogicState state,
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
        getCubitInstance(context).clearSelect();
      }
    }
  });
}

class ServicesLogicState extends BaseLogicState {

  final ServicesConfig config;

  final String? ownerEmail;
  final String locationName;
  final bool hasRights;

  final List<ServiceWrapper> services;

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

  ServicesLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.ownerEmail,
    required this.locationName,
    required this.hasRights,
    required this.services
  });

  @override
  ServicesLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? ownerEmail,
    String? locationName,
    bool? hasRights,
    List<ServiceWrapper>? services
  }) => ServicesLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      locationName: locationName ?? this.locationName,
      hasRights: hasRights ?? this.hasRights,
      services: services ?? this.services
  );
}

@injectable
class ServicesCubit extends BaseCubit<ServicesLogicState> {

  final LocationInteractor _locationInteractor;
  final ServiceInteractor _serviceInteractor;

  ServicesCubit(
      this._locationInteractor,
      this._serviceInteractor,
      @factoryParam ServicesConfig config
  ) : super(
      ServicesLogicState(
          config: config,
          ownerEmail: null,
          locationName: '',
          hasRights: false,
          services: []
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
  }
}

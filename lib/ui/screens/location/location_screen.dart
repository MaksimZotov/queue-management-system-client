import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/location_model.dart';
import '../../router/routes_config.dart';

class LocationWidget extends BaseWidget<LocationConfig> {

  const LocationWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<LocationWidget> createState() => LocationState();
}

class LocationState extends BaseState<
    LocationWidget,
    LocationLogicState,
    LocationCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      LocationLogicState state,
      LocationWidget widget
  ) => state.loading
      ? const Center(
        child: CircularProgressIndicator(),
      )
      : Scaffold(
        appBar: AppBar(
          title: state.locationModel != null
              ? Text(getLocalizations(context).locationPattern(state.locationModel!.name))
              : null
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ButtonWidget(
                  text: getLocalizations(context).services,
                  onClick: () => widget.emitConfig(
                      ServicesConfig(
                          username: widget.config.username,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).servicesSequences,
                  onClick: () => widget.emitConfig(
                      ServicesSequenceConfig(
                          username: widget.config.username,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).queueTypes,
                  onClick: () => widget.emitConfig(
                      QueueTypesConfig(
                          username: widget.config.username,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).queues,
                  onClick: () => widget.emitConfig(
                      QueuesConfig(
                          username: widget.config.username,
                          locationId: widget.config.locationId
                      )
                  )
                )
              ],
            ),
          ),
        ),
  );

  @override
  LocationCubit getCubit() => statesAssembler.getLocationCubit(widget.config);
}

class LocationLogicState extends BaseLogicState {
  
  final LocationConfig config;
  
  final LocationModel? locationModel;

  LocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
    required this.config,
    this.locationModel
  });

  @override
  LocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    LocationModel? locationModel
  }) => LocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      locationModel: locationModel ?? this.locationModel
  );
}

@injectable
class LocationCubit extends BaseCubit<LocationLogicState> {
  final LocationInteractor _locationInteractor;

  LocationCubit(
      this._locationInteractor,
      @factoryParam LocationConfig config
  ) : super(LocationLogicState(config: config));

  @override
  Future<void> onStart() async {
    showLoad();
    await _locationInteractor.getLocation(
        state.config.locationId, 
        state.config.username
    ) 
      ..onSuccess((result) {
        emit(state.copy(locationModel: result.data));
      })
      ..onError((result) { 
        showError(result);
      });
    hideLoad();
  }
}

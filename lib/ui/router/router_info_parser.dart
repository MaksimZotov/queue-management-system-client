import 'package:flutter/material.dart';

import 'routes_config.dart';

class AppRouterInformationParser extends RouteInformationParser<BaseConfig> {

  @override
  Future<BaseConfig> parseRouteInformation(
      RouteInformation routeInformation
  ) async {
    try {
      final uri = Uri.parse(routeInformation.location!);
      List<String> segments = uri.pathSegments;

      switch (segments.length) {
        // "/"
        case 0:
          return InitialConfig();
        case 1:
          switch (segments[0]) {
            // "/authorization"
            case 'authorization':
              return AuthorizationConfig();
            // "/registration"
            case 'registration':
              return RegistrationConfig();
            // "/client?client_id={client_id}&access_key={access_key}"
            case 'client':
              int clientId = int.parse(uri.queryParameters['client_id']!);
              String accessKey = uri.queryParameters['access_key']!;
              return ClientConfig(
                  clientId: clientId,
                  accessKey: accessKey
              );
          }
          break;
        case 2:
           switch (segments[1]) {
             // "/{email}/locations"
             case 'locations':
               return LocationsConfig(email: segments[0]);
           }
           break;
        case 3:
          switch (segments[1]) {
            // "/{email}/locations/{location_id}"
            case 'locations':
              return LocationConfig(
                  email: segments[0],
                  locationId: int.parse(segments[2])
              );
          }
          break;
        case 4:
          switch (segments[1]) {
            case 'locations':
              switch (segments[3]) {
                // "/{email}/locations/{location_id}/services"
                case 'services':
                  return ServicesConfig(
                      email: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{email}/locations/{location_id}/sequences"
                case 'sequences':
                  return ServicesSequencesConfig(
                      email: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{email}/locations/{location_id}/specialists"
                case 'specialists':
                  return SpecialistsConfig(
                      email: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{email}/locations/{location_id}/queues"
                case 'queues':
                  return QueuesConfig(
                      email: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{email}/locations/{location_id}/rights"
                case 'rights':
                  return RightsConfig(
                      email: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{email}/locations/{location_id}/board"
                case 'board':
                  return BoardConfig(
                      email: segments[0],
                      locationId: int.parse(segments[2])
                  );
              }
          }
          break;
        case 5:
          switch (segments[1]) {
            case 'locations':
              switch (segments[3]) {
                // "/{email}/locations/{location_id}/queues/{queue_id}"
                case 'queues':
                  return QueueConfig(
                      email: segments[0],
                      locationId: int.parse(segments[2]),
                      queueId: int.parse(segments[4])
                  );
              }
          }
      }
    } on Exception {
      return ErrorConfig();
    }
    return ErrorConfig();
  }

  @override
  RouteInformation? restoreRouteInformation(BaseConfig configuration) {
    if (configuration is InitialConfig) {
      return const RouteInformation(location: '/');
    }
    if (configuration is AuthorizationConfig) {
      return const RouteInformation(location: '/authorization');
    }
    if (configuration is RegistrationConfig) {
      return const RouteInformation(location: '/registration');
    }
    if (configuration is LocationsConfig) {
      String email = configuration.email;
      return RouteInformation(
          location: '/$email/locations'
      );
    }
    if (configuration is LocationConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$email/locations/$locationId'
      );
    }
    if (configuration is ServicesConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$email/locations/$locationId/services'
      );
    }
    if (configuration is ServicesSequencesConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$email/locations/$locationId/sequences'
      );
    }
    if (configuration is SpecialistsConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$email/locations/$locationId/specialists'
      );
    }
    if (configuration is QueuesConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$email/locations/$locationId/queues'
      );
    }
    if (configuration is QueueConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      int queueId = configuration.queueId;
      return RouteInformation(
          location: '/$email/locations/$locationId/queues/$queueId'
      );
    }
    if (configuration is ClientConfig) {
      int clientId = configuration.clientId;
      String accessKey = configuration.accessKey;
      return RouteInformation(
          location: '/client?client_id=$clientId&access_key=$accessKey'
      );
    }
    if (configuration is RightsConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$email/locations/$locationId/rights'
      );
    }
    if (configuration is BoardConfig) {
      String email = configuration.email;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$email/locations/$locationId/board'
      );
    }
    return null;
  }
}

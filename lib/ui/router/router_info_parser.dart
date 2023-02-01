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
          }
          break;
        case 2:
           switch (segments[1]) {
             // "/{username}/locations"
             case 'locations':
               return LocationsConfig(username: segments[0]);
           }
           break;
        case 3:
          switch (segments[1]) {
            // "/{username}/locations/{location_id}"
            case 'locations':
              return LocationConfig(
                  username: segments[0],
                  locationId: int.parse(segments[2])
              );
          }
          break;
        case 4:
          switch (segments[1]) {
            case 'locations':
              switch (segments[3]) {
                // "/{username}/locations/{location_id}/services"
                case 'services':
                  return ServicesConfig(
                      username: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{username}/locations/{location_id}/sequences"
                case 'sequences':
                  return ServicesSequencesConfig(
                      username: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{username}/locations/{location_id}/types"
                case 'types':
                  return QueueTypesConfig(
                      username: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{username}/locations/{location_id}/queues"
                case 'queues':
                  return QueuesConfig(
                      username: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{username}/locations/{location_id}/rights"
                case 'rights':
                  return RightsConfig(
                      username: segments[0],
                      locationId: int.parse(segments[2])
                  );
                // "/{username}/locations/{location_id}/board"
                case 'board':
                  return BoardConfig(
                      username: segments[0],
                      locationId: int.parse(segments[2])
                  );
                case 'client':
                  int clientId = int.parse(uri.queryParameters['client_id']!);
                  String accessKey = uri.queryParameters['access_key']!;
                  // "/{username}/locations/{location_id}/client?client_id={client_id}&access_key={access_key}"
                  return ClientConfig(
                      username: segments[0],
                      locationId: int.parse(segments[2]),
                      clientId: clientId,
                      accessKey: accessKey
                  );
              }
          }
          break;
        case 5:
          switch (segments[1]) {
            case 'locations':
              switch (segments[3]) {
                // "/{username}/locations/{location_id}/queues/{queue_id}"
                case 'queues':
                  return QueueConfig(
                      username: segments[0],
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
      String username = configuration.username;
      return RouteInformation(
          location: '/$username/locations'
      );
    }
    if (configuration is LocationConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$username/locations/$locationId'
      );
    }
    if (configuration is ServicesConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$username/locations/$locationId/services'
      );
    }
    if (configuration is ServicesSequencesConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$username/locations/$locationId/sequences'
      );
    }
    if (configuration is QueueTypesConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$username/locations/$locationId/types'
      );
    }
    if (configuration is QueuesConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$username/locations/$locationId/queues'
      );
    }
    if (configuration is QueueConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      int queueId = configuration.queueId;
      return RouteInformation(
          location: '/$username/locations/$locationId/queues/$queueId'
      );
    }
    if (configuration is ClientConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      int clientId = configuration.clientId;
      String accessKey = configuration.accessKey;
      return RouteInformation(
          location: '/$username/locations/$locationId/client?client_id=$clientId&access_key=$accessKey'
      );
    }
    if (configuration is RightsConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$username/locations/$locationId/rights'
      );
    }
    if (configuration is BoardConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/$username/locations/$locationId/board'
      );
    }
    return null;
  }
}

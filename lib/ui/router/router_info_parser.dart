import 'package:flutter/material.dart';

import 'routes_config.dart';

class AppRouterInformationParser
    extends RouteInformationParser<BaseConfig> {

  @override
  Future<BaseConfig> parseRouteInformation(
      RouteInformation routeInformation
  ) async {
    try {
      final uri = Uri.parse(routeInformation.location!);
      List<String> segments = uri.pathSegments;

      switch (segments.length) {
        case 0:
          return InitialConfig();
        case 1:
          switch (segments[0]) {
            case 'authorization':
              return AuthorizationConfig();
            case 'registration':
              return RegistrationConfig();
          }
          break;
        case 2:
           switch (segments[0]) {
             case 'locations':
               return LocationsConfig(username: segments[1]);
           }
           break;
        case 3:
          switch (segments[0]) {
            case 'locations':
              return QueuesConfig(
                  username: segments[1],
                  locationId: int.parse(segments[2])
              );
          }
          break;
        case 4:
          switch (segments[0]) {
            case 'locations':
              return QueueConfig(
                  username: segments[1],
                  locationId: int.parse(segments[2]),
                  queueId: int.parse(segments[3])
              );
          }
          break;
        case 6:
          switch (segments[1]) {
            case 'locations':
              return ClientConfig(
                  username: segments[0],
                  locationId: int.parse(segments[2]),
                  queueId: int.parse(segments[4])
              );
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
          location: '/locations/$username'
      );
    }
    if (configuration is QueuesConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/locations/$username/$locationId'
      );
    }
    if (configuration is QueueConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      int queueId = configuration.queueId;
      return RouteInformation(
          location: '/locations/$username/$locationId/$queueId'
      );
    }
    if (configuration is ClientConfig) {
      String username = configuration.username;
      int locationId = configuration.locationId;
      int queueId = configuration.queueId;
      return RouteInformation(
          location: '/$username/locations/$locationId/queues/$queueId/client'
      );
    }
    return null;
  }
}

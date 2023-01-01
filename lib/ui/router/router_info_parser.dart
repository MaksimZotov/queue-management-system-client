import 'package:flutter/material.dart';

import 'routes_config.dart';

class AppRouterInformationParser
    extends RouteInformationParser<BaseConfig> {

  @override
  Future<BaseConfig> parseRouteInformation(
      RouteInformation routeInformation
  ) async {

    String? route = routeInformation.location;
    if (route == null) {
      return ErrorConfig();
    }

    final uri = Uri.parse(route);
    List<String> segments = uri.pathSegments;
    
    if (segments.isEmpty) {
      return InitialConfig();
    }

    String first = segments.first;
    if (segments.length == 1) {
      switch (first) {
        case 'authorization':
          return AuthorizationConfig();
        case 'registration':
          return RegistrationConfig();
        case 'locations':
          if (uri.queryParameters.containsKey('username')) {
            return LocationsConfig(
                username: uri.queryParameters['username']
            );
          }
          break;
        case 'queues':
          if (uri.queryParameters.containsKey('location_id')) {
            int? locationId = int.tryParse(uri.queryParameters['location_id'] ?? '');
            if (locationId != null) {
              return QueuesConfig(
                  locationId: locationId
              );
            }
          }
      }
    }
    
    String second = segments[1];
    if (segments.length == 2) {
      switch (first) {
        case 'queues':
          int? queueId = int.tryParse(second);
          if (queueId != null) {
            return QueueConfig(
                queueId: queueId
            );
          }
      }
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
      String username = configuration.username.toString();
      return RouteInformation(
          location: '/locations?username=$username'
      );
    }
    if (configuration is QueuesConfig) {
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/queues?location_id=$locationId'
      );
    }
    if (configuration is QueueConfig) {
      int queueId = configuration.queueId;
      return RouteInformation(
          location: '/queues/$queueId'
      );
    }
    return null;
  }
}

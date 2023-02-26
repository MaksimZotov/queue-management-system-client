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
        case 3:
          switch (segments[0]) {
          case 'accounts':
            switch (segments[2]) {
              // "/accounts/{account_id}/locations"
              case 'locations':
                return LocationsConfig(
                    accountId: int.parse(segments[1])
                );
            }
          }
          break;
        case 4:
          switch (segments[0]) {
            case 'accounts':
              switch (segments[2]) {
                // "/accounts/{account_id}/locations/{location_id}"
                case 'locations':
                  return LocationConfig(
                      accountId: int.parse(segments[1]),
                      locationId: int.parse(segments[3])
                  );
              }
              break;
          }
          break;
        case 5:
          switch (segments[0]) {
            case 'accounts':
              switch (segments[2]) {
                case 'locations':
                  switch (segments[4]) {
                    // "/accounts/{account_id}/locations/{location_id}/services"
                    case 'services':
                      return ServicesConfig(
                          accountId: int.parse(segments[1]),
                          locationId: int.parse(segments[3])
                      );
                    // "/accounts/{account_id}/locations/{location_id}/sequences"
                    case 'sequences':
                      return ServicesSequencesConfig(
                          accountId: int.parse(segments[1]),
                          locationId: int.parse(segments[3])
                      );
                    // "/accounts/{account_id}/locations/{location_id}/specialists"
                    case 'specialists':
                      return SpecialistsConfig(
                          accountId: int.parse(segments[1]),
                          locationId: int.parse(segments[3])
                      );
                    // "/accounts/{account_id}/locations/{location_id}/queues"
                    case 'queues':
                      return QueuesConfig(
                          accountId: int.parse(segments[1]),
                          locationId: int.parse(segments[3])
                      );
                    // "/accounts/{account_id}/locations/{location_id}/rights"
                    case 'rights':
                      return RightsConfig(
                          accountId: int.parse(segments[1]),
                          locationId: int.parse(segments[3])
                      );
                    // "/accounts/{account_id}/locations/{location_id}/board"
                    case 'board':
                      return BoardConfig(
                          accountId: int.parse(segments[1]),
                          locationId: int.parse(segments[3])
                      );
                  }
              }
              break;
          }
          break;
        case 6:
          switch (segments[0]) {
            case 'accounts':
              switch (segments[2]) {
                case 'locations':
                  switch (segments[4]) {
                    // "/accounts/{account_id}/locations/{location_id}/queues/{queue_id}"
                    case 'queues':
                      return QueueConfig(
                          accountId: int.parse(segments[1]),
                          locationId: int.parse(segments[3]),
                          queueId: int.parse(segments[5])
                      );
                  }
              }
              break;
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
      int accountId = configuration.accountId;
      return RouteInformation(
          location: '/accounts/$accountId/locations'
      );
    }
    if (configuration is LocationConfig) {
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId'
      );
    }
    if (configuration is ServicesConfig) {
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId/services'
      );
    }
    if (configuration is ServicesSequencesConfig) {
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId/sequences'
      );
    }
    if (configuration is SpecialistsConfig) {
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId/specialists'
      );
    }
    if (configuration is QueuesConfig) {
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId/queues'
      );
    }
    if (configuration is QueueConfig) {
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      int queueId = configuration.queueId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId/queues/$queueId'
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
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId/rights'
      );
    }
    if (configuration is BoardConfig) {
      int accountId = configuration.accountId;
      int locationId = configuration.locationId;
      return RouteInformation(
          location: '/accounts/$accountId/locations/$locationId/board'
      );
    }
    return null;
  }
}

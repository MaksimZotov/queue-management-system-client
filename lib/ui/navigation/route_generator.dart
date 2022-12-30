import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/screens/location/locations.dart';
import 'package:queue_management_system_client/ui/screens/verification/authorization.dart';
import 'package:queue_management_system_client/ui/screens/verification/confirmation.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/screens/verification/select.dart';

class Routes {
  Routes._();

  static const String toSelect = 'toSelect';
  static const String toRegistration = 'toRegistration';
  static const String toConfirmation = 'toConfirmation';
  static const String toAuthorization = 'toAuthorization';
  static const String toLocations = 'toLocations';
}

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final route = settings.name;
    final args = settings.arguments;

    switch (route) {
      case Routes.toSelect:
        return MaterialPageRoute(
          builder: (ctx) => const SelectWidget(),
        );
      case Routes.toRegistration:
        return MaterialPageRoute(
          builder: (ctx) => const RegistrationWidget(),
        );
      case Routes.toConfirmation:
        return MaterialPageRoute(
          builder: (ctx) => ConfirmationWidget(
              params: args as ConfirmationParams
          ),
        );
      case Routes.toAuthorization:
        return MaterialPageRoute(
          builder: (ctx) => const AuthorizationWidget(),
        );
      case Routes.toLocations:
        return MaterialPageRoute(
          builder: (ctx) => LocationsWidget(
            params: args as LocationsParams,
          ),
        );
    }
    throw Exception("Incorrect route: $route");
  }
}
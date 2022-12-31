import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/screens/location/locations.dart';
import 'package:queue_management_system_client/ui/screens/queue/queue.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues.dart';
import 'package:queue_management_system_client/ui/screens/verification/authorization.dart';
import 'package:queue_management_system_client/ui/screens/verification/confirmation.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/screens/verification/select.dart';

class Routes {
  Routes._();

  static const String initial = '/';
  static const String registration = '/registration';
  static const String confirmation = '/confirmation';
  static const String authorization = '/authorization';

  static const String locations = '/locations';

  static const String queues = '/locations/';
  static const String queue = '/queues';
}

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final route = settings.name;
    final args = settings.arguments;

    return _GeneratePageRoute(
        widget: getWidget(route, args),
        routeName: getRouteName(route, args)
    );
  }

  static Widget getWidget(String? route, Object? args) {
    switch (route) {
      case Routes.initial:
        return const SelectWidget();
      case Routes.registration:
        return const RegistrationWidget();
      case Routes.confirmation:
        return ConfirmationWidget(params: args as ConfirmationParams);
      case Routes.authorization:
        return const AuthorizationWidget();
      case Routes.locations:
        return LocationsWidget(params: args as LocationsParams);
      case Routes.queues:
        return QueuesWidget(params: args as QueuesParams);
      case Routes.queue:
        return QueueWidget(params: args as QueueParams);
    }
    throw Exception("Incorrect route: $route");
  }

  static String getRouteName(String? route, Object? args) {
    switch (route) {
      case Routes.initial:
        return Routes.initial;
      case Routes.registration:
        return Routes.registration;
      case Routes.confirmation:
        return Routes.confirmation;
      case Routes.authorization:
        return Routes.authorization;
      case Routes.locations:
        LocationsParams params = args as LocationsParams;
        String postFix = (params.username == null) ? '/me' : '/${params.username}';
        return Routes.locations + postFix;
      case Routes.queues:
        QueuesParams params = args as QueuesParams;
        String postFix = '${params.locationId}/queues';
        return Routes.queues + postFix;
      case Routes.queue:
        QueueParams params = args as QueueParams;
        String postFix = '/${params.queueId}';
        return Routes.queue + postFix;
    }
    throw Exception("Incorrect route: $route");
  }
}

class _GeneratePageRoute extends PageRouteBuilder {
  final Widget widget;
  final String routeName;

  _GeneratePageRoute({required this.widget, required this.routeName})
      : super(
      settings: RouteSettings(name: routeName),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return widget;
      },
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      });
}
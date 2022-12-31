import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/screens/location/locations.dart';
import 'package:queue_management_system_client/ui/screens/queue/queue.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues.dart';
import 'package:queue_management_system_client/ui/screens/verification/authorization.dart';
import 'package:queue_management_system_client/ui/screens/verification/confirmation.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/screens/verification/select.dart';

class RouteToArgs {
  final String route;
  final Object? args;

  RouteToArgs({
    required this.route,
    this.args
  });
}

class Routes {

  Routes._();

  static const String initial = '/';
  static const String registration = '/registration';
  static const String confirmation = '/confirmation';
  static const String authorization = '/authorization';

  static const String locationsInAccount = '/locations/';

  static const String queuesInLocation = '/queues?';
  static const String queueWithId = '/queues/';
}

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final route = settings.name;
    final args = settings.arguments;

    print('FFFFFFFFFFFFFFFFFFFFFFFFFFF $route');

    RouteToArgs routeToArgs = _getRouteNameToArgs(route, args);

    return _GeneratePageRoute(
        widget: getWidget(routeToArgs.route, routeToArgs.args),
        routeName: routeToArgs.route
    );
  }

  static Widget getWidget(String route, Object? args) {
    Uri uri = Uri.parse(route);
    final String startRoute;
    if (uri.pathSegments.isEmpty) {
      startRoute = Routes.initial;
    } else {
      startRoute = '/${uri.pathSegments.first}';
    }
    switch (startRoute) {
      case Routes.initial:
        return const SelectWidget();
      case Routes.registration:
        return const RegistrationWidget();
      case Routes.authorization:
        return const AuthorizationWidget();
    }
    switch (args.runtimeType) {
      case ConfirmationParams:
        return ConfirmationWidget(params: args as ConfirmationParams);
      case LocationsParams:
        return LocationsWidget(params: args as LocationsParams);
      case QueuesParams:
        return QueuesWidget(params: args as QueuesParams);
      case QueueParams:
        return QueueWidget(params: args as QueueParams);
    }
    throw Exception("Incorrect route: $route");
  }

  /// Получение полного пути и аргументов
  static RouteToArgs _getRouteNameToArgs(String? route, Object? args) {
    if (route == null) {
      return RouteToArgs(route: Routes.initial);
    }

    // Вначале проверяем случай, когда переход совершен через приложение
    String? checkedRoute = _getRouteFromStartRouteAndArgs(route, args);
    if (checkedRoute != null) {
      return RouteToArgs(route: checkedRoute, args: args);
    }

    // Затем проверяем случай с переходом напрямую через URL
    Object? checkedArgs = _getArgsFromRoute(route);
    if (checkedArgs != null) {
      return RouteToArgs(route: route, args: checkedArgs);
    }

    return RouteToArgs(route: Routes.initial);
  }

  /// Получение полного пути на основе начального пути и переданных аргументов
  static String? _getRouteFromStartRouteAndArgs(String startRoute, Object? args) {
    try {
      switch (startRoute) {
        case Routes.initial:
          return Routes.initial;
        case Routes.registration:
          return Routes.registration;
        case Routes.confirmation:
          return Routes.confirmation;
        case Routes.authorization:
          return Routes.authorization;
        case Routes.locationsInAccount:
          LocationsParams params = args as LocationsParams;
          String postFix = (params.username == null) ? 'me' : params.username!;
          return Routes.locationsInAccount + postFix;
        case Routes.queuesInLocation:
          QueuesParams params = args as QueuesParams;
          String postFix = 'location_id=${params.locationId}';
          return Routes.queuesInLocation + postFix;
        case Routes.queueWithId:
          QueueParams params = args as QueueParams;
          String postFix = params.queueId.toString();
          return Routes.queueWithId + postFix;
      }
      return null;
    } on Exception {
      return null;
    }
  }

  /// Получение аргументов на основе полного пути
  static Object? _getArgsFromRoute(String route) {
    try {
      final uri = Uri.parse(route);
      final path = uri.path;
      if (path.startsWith(RegExp(Routes.locationsInAccount))) {
        return LocationsParams(
            username: uri.pathSegments.last
        );
      } else if (path.startsWith(RegExp(Routes.queuesInLocation))) {
        return QueuesParams(
            locationId: int.parse(uri.queryParameters['location_id']!)
        );
      } else if (path.startsWith(RegExp(Routes.queueWithId))) {
        return QueueParams(
          queueId: int.parse(uri.pathSegments.last),
        );
      } else {
        return null;
      }
    } on Exception {
      return null;
    }
  }
}

class _GeneratePageRoute extends PageRouteBuilder {
  final Widget widget;
  final String routeName;

  _GeneratePageRoute({required this.widget, required this.routeName}) : super(
      settings: RouteSettings(name: routeName),
      pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation
      ) {
        return widget;
      },
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child
      ) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      });
}
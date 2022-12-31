import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/navigation/route_generator.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppState();
}


class AppState extends State<AppWidget> {

  @override
  Widget build(BuildContext ctx) {
    return const MaterialApp(
      initialRoute: Routes.initial,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
import 'package:flutter/material.dart';

import '../../router/router_delegate.dart';
import '../../router/router_info_parser.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  AppRouterDelegate routerDelegate = AppRouterDelegate();
  AppRouterInformationParser routerInformationParser = AppRouterInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
          primarySwatch: Colors.teal,
          textTheme: const TextTheme(
            headline1: TextStyle(color: Colors.grey),
            headline2: TextStyle(color: Colors.grey),
            bodyText2: TextStyle(color: Colors.grey),
            subtitle1: TextStyle(color: Colors.black),
          ),
      ),
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: routerInformationParser,
    );
  }
}

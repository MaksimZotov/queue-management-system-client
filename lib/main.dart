import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/screens/app/app_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'di/main/main.dart';

void main() {
  setup();
  usePathUrlStrategy();
  runApp(const AppWidget());
}

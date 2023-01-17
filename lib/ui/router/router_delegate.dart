import 'package:flutter/material.dart';
import 'routes_config.dart';

class AppRouterDelegate extends RouterDelegate<BaseConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BaseConfig> {

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  BaseConfig? config;

  List<Page> get pages {
    List<Page> pages = [];
    BaseConfig? curConfig = config;
    while (curConfig != null) {
      pages.add(curConfig.getPage(emitConfig));
      curConfig = curConfig.getPrevConfig();
    }
    if (pages.isEmpty) {
      return [InitialConfig().getPage(emitConfig)];
    }
    return pages.reversed.toList();
  }

  @override
  BaseConfig get currentConfiguration {
    if (config == null) {
      return InitialConfig();
    }
    return config!;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        config = config?.getPrevConfig();
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BaseConfig configuration) async {
    config = configuration;
  }

  void emitConfig(BaseConfig configuration) {
    config = configuration;
    notifyListeners();
  }
}

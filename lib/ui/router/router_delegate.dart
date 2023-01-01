import 'package:flutter/material.dart';
import 'routes_config.dart';

class AppRouterDelegate extends RouterDelegate<BaseConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BaseConfig> {

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  List<BaseConfig> configs = [];

  List<Page> get pages {
    List<Page> pages = configs
        .map((config) => config.getPage(emitConfig))
        .toList();
    if (pages.isEmpty) {
      return [InitialConfig().getPage(emitConfig)];
    }
    return pages;
  }

  @override
  BaseConfig get currentConfiguration {
    print('FFFFFFFFFFFFFFFFFFFFFFFFF');
    print('currentConfiguration');
    print(configs);
    if (configs.isEmpty) {
      return InitialConfig();
    }
    return configs.last;
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
        print('FFFFFFFFFFFFFFFFFFFFFFFFF');
        print('onPopPage');
        print(configs);
        configs.removeLast();
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BaseConfig configuration) async {
    print('FFFFFFFFFFFFFFFFFFFFFFFFF');
    print('setNewRoutePath');
    print(configs);
    configs.add(configuration);
  }

  void emitConfig(BaseConfig configuration) {
    print('FFFFFFFFFFFFFFFFFFFFFFFFF');
    print('emitConfig');
    print(configs);
    configs.add(configuration);
    notifyListeners();
  }
}

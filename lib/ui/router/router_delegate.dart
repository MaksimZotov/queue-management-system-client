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
    print('FFFFFFFFFFFFFFFFFFFFFFFFF');
    print('pages');
    print(pages.reversed.toList());
    return pages.reversed.toList();
  }

  @override
  BaseConfig get currentConfiguration {
    print('FFFFFFFFFFFFFFFFFFFFFFFFF');
    print('currentConfiguration');
    print(config);
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
          print('FFFFFFFFFFFFFFFFFFFFFFFFF');
          print('onPopPageTEST');
          return false;
        }
        print('FFFFFFFFFFFFFFFFFFFFFFFFF');
        print('onPopPage');
        print(config);
        config = config?.getPrevConfig();
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BaseConfig configuration) async {
    print('FFFFFFFFFFFFFFFFFFFFFFFFF');
    print('setNewRoutePath');
    config = configuration;
    print(config);
  }

  void emitConfig(BaseConfig configuration) {
    print('FFFFFFFFFFFFFFFFFFFFFFFFF');
    print('emitConfig');
    config = configuration;
    print(config);
    notifyListeners();
  }
}

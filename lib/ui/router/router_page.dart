import 'package:flutter/cupertino.dart';

class RouterPage extends Page {
  final Widget child;

  const RouterPage({
    required this.child,
    required LocalKey key
  }) : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation
      ) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool checkNullState() {
    if (navigatorKey.currentState == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    print(navigatorKey.currentState!.toString());
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  void goBack({Map<String, dynamic>? result}) {
    return navigatorKey.currentState!.pop(result ?? {});
  }
}

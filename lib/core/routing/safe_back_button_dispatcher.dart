import 'package:flutter/widgets.dart';

class SafeBackButtonDispatcher extends RootBackButtonDispatcher {
  @override
  Future<bool> didPopRoute() async {
    try {
      return await super.didPopRoute();
    } on StateError catch (error) {
      if (error.message == 'No element') {
        return false;
      }
      rethrow;
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/routing/app_router.dart';

void main() {
  test('app router starts on Today', () {
    final router = appRouter();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    router.dispose();
  });
}

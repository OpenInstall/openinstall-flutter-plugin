import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('openinstall_flutter_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}

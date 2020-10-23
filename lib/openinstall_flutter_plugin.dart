import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> data);

class OpeninstallFlutterPlugin {
  // 单例
  static final OpeninstallFlutterPlugin _instance =
      new OpeninstallFlutterPlugin._internal();

  factory OpeninstallFlutterPlugin() => _instance;

  OpeninstallFlutterPlugin._internal();

  Future defaultHandler() async {}

  EventHandler _wakeupHandler;
  EventHandler _installHandler;

  static const MethodChannel _channel =
      const MethodChannel('openinstall_flutter_plugin');

  void init(EventHandler wakeupHandler, [bool permission = false]) {
    _wakeupHandler = wakeupHandler;
    _channel.invokeMethod("registerWakeup");
    _channel.setMethodCallHandler(_handleMethod);

    if (Platform.isAndroid) {
      // registerWakeup 将在初始化后自动调用
      if (permission) {
        _channel.invokeMethod("initWithPermission");
      } else {
        _channel.invokeMethod("init");
      }
    }
  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onWakeupNotification":
        if (_wakeupHandler == null) {
          return defaultHandler();
        }
        return _wakeupHandler(call.arguments.cast<String, dynamic>());
      case "onInstallNotification":
        if (_installHandler == null) {
          return defaultHandler();
        }
        return _installHandler(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }

  void install(EventHandler installHandler, [int seconds = 10]) {
    var args = new Map();
    args["seconds"] = seconds;
    this._installHandler = installHandler;
    _channel.invokeMethod('getInstall', args);
  }

  void reportRegister() {
    _channel.invokeMethod('reportRegister');
  }

  void reportEffectPoint(String pointId, int pointValue) {
    var args = new Map();
    args["pointId"] = pointId;
    args["pointValue"] = pointValue;
    _channel.invokeMethod('reportEffectPoint', args);
  }
}

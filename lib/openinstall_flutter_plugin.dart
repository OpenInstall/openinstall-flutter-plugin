import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> data);

class OpeninstallFlutterPlugin {
  // 单例
  static final OpeninstallFlutterPlugin _instance = new OpeninstallFlutterPlugin._internal();
  factory OpeninstallFlutterPlugin() => _instance;

  OpeninstallFlutterPlugin._internal();

  Future defaultHandler() async {}

  late EventHandler _wakeupHandler;
  late EventHandler _installHandler;

  static const MethodChannel _channel = const MethodChannel('openinstall_flutter_plugin');

  // 旧版本使用，保留一段时间，防止 npm 自动升级使用最新版本插件出现问题
  void config(bool adEnabled, String? oaid, String? gaid) {
    if (Platform.isAndroid) {
      var args = new Map();
      args["adEnabled"] = adEnabled;
      args["oaid"] = oaid;
      args['gaid'] = gaid;
      _channel.invokeMethod('config', args);
    } else {
      // 仅使用于 Android 平台
    }
  }

  void configAndroid(Map options) {
    if (Platform.isAndroid) {
      _channel.invokeMethod('config', options);
    } else {
      // 仅使用于 Android 平台
    }
  }

  // initWithPermission 将移除
  // 保留一段时间，防止 npm 自动升级使用最新版本插件出现问题
  void init(EventHandler wakeupHandler, [bool permission = false]) {
    _wakeupHandler = wakeupHandler;
    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod("registerWakeup");
    if (Platform.isAndroid) {
      if (permission) {
        _channel.invokeMethod("initWithPermission");
      } else {
        _channel.invokeMethod("init");
      }
    } else {
      print( "OpenInstallSDK:插件版本>=1.3.1后，iOS环境下通用链接和scheme拉起的原生代理方法由插件内部来处理，如果出现拉起问题，请参考官方文档处理");
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

  Future _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onWakeupNotification":
        return _wakeupHandler(call.arguments.cast<String, dynamic>());
      case "onInstallNotification":
        return _installHandler(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }

}

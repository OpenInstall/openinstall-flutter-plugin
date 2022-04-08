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
    print("OpenInstallPlugin:config(bool adEnabled, String? oaid, String? gaid) 后续版本将移除，请使用configAndroid(Map options)");
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

  // 广告平台配置，请参考文档
  void configAndroid(Map options) {
    if (Platform.isAndroid) {
      _channel.invokeMethod('config', options);
    } else {
      // 仅使用于 Android 平台
    }
  }

  // wakeupHandler 拉起回调.
  // alwaysCallback 是否总是有回调。当值为true时，只要触发了拉起方法调用，就会有回调
  // permission 初始化时是否申请 READ_PHONE_STATE 权限，已废弃。请用户自行进行权限申请
  void init(EventHandler wakeupHandler, {bool alwaysCallback = false, bool permission = false}) {
    _wakeupHandler = wakeupHandler;
    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod("registerWakeup");
    if (Platform.isAndroid) {
      if (permission) {
        print("OpenInstallPlugin.initWithPermission 后续版本将移除，请自行进行权限申请");
        var args = new Map();
        args["alwaysCallback"] = alwaysCallback;
        _channel.invokeMethod("initWithPermission", args);
      } else {
        var args = new Map();
        args["alwaysCallback"] = alwaysCallback;
        _channel.invokeMethod("init", args);
      }
    } else {
      print("OpenInstallPlugin:插件版本>=1.3.1后，iOS环境下通用链接和scheme拉起的原生代理方法由插件内部来处理，如果出现拉起问题，请参考官方文档处理");
    }
  }

  // SDK内部将会一直保存安装数据，每次调用install方法都会返回值。
  // 如果调用install获取到数据并处理了自己的业务，后续不想再被触发，那么可以自己在业务调用成功时，设置一个标识，不再调用install方法
  void install(EventHandler installHandler, [int seconds = 10]) {
    var args = new Map();
    args["seconds"] = seconds;
    this._installHandler = installHandler;
    _channel.invokeMethod('getInstall', args);
  }

  // 只有在用户进入应用后在较短时间内需要返回安装参数，但是又不想影响参数获取精度时使用。
  // 在retry为true的情况下，后续再次通过install依然可以获取安装数据
  // 通常情况下，请使用 install 方法获取安装参数
  void getInstallCanRetry(EventHandler installHandler, [int seconds = 3]) {
    if (Platform.isAndroid) {
      var args = new Map();
      args["seconds"] = seconds;
      this._installHandler = installHandler;
      _channel.invokeMethod('getInstallCanRetry', args);
    } else {
      // 仅使用于 Android 平台
    }
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
    print(call.method);
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

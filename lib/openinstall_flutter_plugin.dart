import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef Future EventHandler(Map<String, Object> data);

class OpeninstallFlutterPlugin {
  // 单例
  static final OpeninstallFlutterPlugin _instance = new OpeninstallFlutterPlugin._internal();

  factory OpeninstallFlutterPlugin() => _instance;

  OpeninstallFlutterPlugin._internal();

  Future defaultHandler() async {}

  late EventHandler _wakeupHandler;
  late EventHandler _installHandler;

  static const MethodChannel _channel = const MethodChannel('openinstall_flutter_plugin');

  void setDebug(bool enabled) {
    if (Platform.isAndroid) {
      var args = new Map();
      args["enabled"] = enabled;
      _channel.invokeMethod('setDebug', args);
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

  // 关闭剪切板读取
  void clipBoardEnabled(bool enabled) {
    if (Platform.isAndroid) {
      var args = new Map();
      args["enabled"] = enabled;
      _channel.invokeMethod('clipBoardEnabled', args);
    } else {
      // 仅使用于 Android 平台
    }
  }

  //设置参数并初始化
  //options可设置参数：
  //AdPlatformEnable：必要，是否开启广告平台统计功能
  //ASAEnable：必要，是否开启ASA功能
  //ASADebug：可选，使用ASA功能时是否开启debug模式,正式环境中请关闭
  //idfaStr：可选，用户可以自行传入idfa字符串，不传则插件内部会获取，通过其它插件获取的idfa字符串一般格式为xxxx-xxxx-xxxx-xxxx
  void configIos(Map options) {
    if (Platform.isAndroid) {
      //仅使用于 iOS 平台
    } else {
      _channel.invokeMethod("config", options);
    }
  }

  // wakeupHandler 拉起回调.
  // alwaysCallback 是否总是有回调。当值为true时，只要触发了拉起方法调用，就会有回调
  // permission 初始化时是否申请 READ_PHONE_STATE 权限，已废弃。请用户自行进行权限申请
  void init(EventHandler wakeupHandler, [bool alwaysCallback = false]) {
    _wakeupHandler = wakeupHandler;
    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod("registerWakeup");
    if (Platform.isAndroid) {
      var args = new Map();
      args["alwaysCallback"] = alwaysCallback;
      _channel.invokeMethod("init", args);
    } else {
      print("插件版本>=2.3.1后，由于整合了广告和ASA系统，iOS平台将通过用户手动调用init方法初始化SDK，需要广告平台或者ASA统计服务的请在init方法前调用configIos方法配置参数");
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
  // 在shouldRetry为true的情况下，后续再次通过install依然可以获取安装数据
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

  void reportEffectPoint(String pointId, int pointValue, [Map<String, String>? extraMap]) {
    var args = new Map();
    args["pointId"] = pointId;
    args["pointValue"] = pointValue;
    if (extraMap != null) {
      args["extras"] = extraMap;
    }
    _channel.invokeMethod('reportEffectPoint', args);
  }

  Future<Map<Object?, Object?>> reportShare(String shareCode, String platform) async {
    var args = new Map();
    args["shareCode"] = shareCode;
    args["platform"] = platform;
    Map<Object?, Object?> data = await _channel.invokeMethod('reportShare', args);
    return data;
  }

  Future<String?> getOpid() async {
    print("getOpid 当初始化未完成时，将返回空，请在业务需要时再获取，并且使用时做空判断");
    if (Platform.isAndroid) {
      String? opid = await _channel.invokeMethod('getOpid');
      return opid;
    } else {
      String? opid = await _channel.invokeMethod('getOpid');
      return opid;
    }
  }

  void setChannel(String channelCode) {
    if (Platform.isAndroid) {
      var args = new Map();
      args["channelCode"] = channelCode;
      _channel.invokeMethod('setChannel', args);
    } else {
      // 仅使用于 Android 平台
    }
  }

  Future _handleMethod(MethodCall call) async {
    print(call.method);
    switch (call.method) {
      case "onWakeupNotification":
        return _wakeupHandler(call.arguments.cast<String, Object>());
      case "onInstallNotification":
        return _installHandler(call.arguments.cast<String, Object>());
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }
}

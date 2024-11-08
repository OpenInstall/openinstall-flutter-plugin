import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String wakeUpLog = "";
  String installLog = "";
  late OpeninstallFlutterPlugin _openinstallFlutterPlugin;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _openinstallFlutterPlugin = OpeninstallFlutterPlugin();
    // _openinstallFlutterPlugin.setDebug(false);
    _openinstallFlutterPlugin.init(wakeupHandler);
    // 错误：应该在业务需要时再调用 install 获取参数
    // _openinstallFlutterPlugin.install(installHandler);

    setState(() {});
  }

  @override
  void activate() {
    // TODO: implement activate
    super.activate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('openinstall plugin demo'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(installLog, style: TextStyle(fontSize: 18)),
              Text(wakeUpLog, style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _openinstallFlutterPlugin.install(installHandler, 10);
                },
                child: Text('getInstall', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _openinstallFlutterPlugin.reportRegister();
                },
                child: const Text('reportRegister',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _openinstallFlutterPlugin.reportEffectPoint("effect_test", 1);
                },
                child: const Text('reportEffectPoint',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Map<String, String> extraMap = {
                    "systemVersion": Platform.operatingSystemVersion,
                    "flutterVersion": Platform.version
                  };
                  _openinstallFlutterPlugin.reportEffectPoint(
                      "effect_detail", 1, extraMap);
                },
                child: const Text('reportEffectDetail',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () {
                    _openinstallFlutterPlugin
                        .reportShare("123456", "WechatSession")
                        .then((data) =>
                            print("reportShare : " + data.toString()));
                  },
                  child: const Text('reportShare',
                      style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }

  Future installHandler(Map<String, Object> data) async {
    print("installHandler : " + data.toString());
    setState(() {
      installLog = "install result : channel=" + data['channelCode'].toString()
          + ", data=" + data['bindData'].toString()
          + ", shouldRetry=" + data['shouldRetry'].toString() + "\n";
    });
  }

  Future wakeupHandler(Map<String, Object> data) async {
    print("wakeupHandler : " + data.toString());
    setState(() {
      wakeUpLog = "wakeup result : channel=" + data['channelCode'].toString()
          + ", data=" + data['bindData'].toString() + "\n";
    });
  }
}

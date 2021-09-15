# openinstall_flutter_plugin_example

``` dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String log;
  OpeninstallFlutterPlugin _openinstallFlutterPlugin;

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

    _openinstallFlutterPlugin = new OpeninstallFlutterPlugin();
    _openinstallFlutterPlugin.init(wakeupHandler);
    _openinstallFlutterPlugin.install(installHandler);

    setState(() {
      log = "";
    });
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
              Text(log, style: TextStyle(fontSize: 20)),
              const SizedBox(height: 30),
              RaisedButton(
                onPressed: () {
                  _openinstallFlutterPlugin.install(installHandler);
                },
                child: Text('registerInstall', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 30),
              RaisedButton(
                onPressed: () {
                  _openinstallFlutterPlugin.reportRegister();
                },
                child: const Text('reportRegister',
                    style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 30),
              RaisedButton(
                onPressed: () {
                  _openinstallFlutterPlugin.reportEffectPoint("effect_test", 1);
                },
                child: const Text('reportEffectPoint',
                    style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future installHandler(Map<String, dynamic> data) async {
    setState(() {
      log = "install result : channel=" +
          data['channelCode'] +
          ", data=" +
          data['bindData'].toString() +
          "\n";
    });
  }

  Future wakeupHandler(Map<String, dynamic> data) async {
    setState(() {
      log = "wakeup result : channel=" +
          data['channelCode'] +
          ", data=" +
          data['bindData'].toString() +
          "\n";
    });
  }
}

```

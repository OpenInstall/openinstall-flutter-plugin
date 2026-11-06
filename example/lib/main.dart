import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'openinstall plugin demo',
      home: OpeninstallDemoPage(),
    );
  }
}

class OpeninstallDemoPage extends StatefulWidget {
  @override
  _OpeninstallDemoPageState createState() => _OpeninstallDemoPageState();
}

class _OpeninstallDemoPageState extends State<OpeninstallDemoPage> {
  final OpeninstallFlutterPlugin _openinstallFlutterPlugin =
      OpeninstallFlutterPlugin();

  String _installLog = "";
  String _wakeUpLog = "";
  String _opidLog = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // 建议在 init 之前开启调试日志，正式发布版本请关闭
    _openinstallFlutterPlugin.setDebug(true);
    // 日志监听仅打印到控制台，便于排查问题
    _openinstallFlutterPlugin.setLogListener(logHandler);

    // 广告平台/ASA 配置请按文档在 init 之前调用
    // if (Platform.isAndroid) {
    //   var adConfig = new Map();
    //   adConfig["adEnabled"] = true;
    //   _openinstallFlutterPlugin.configAndroid(adConfig);
    // } else {
    //   var adConfig = new Map();
    //   adConfig["adEnable"] = true;
    //   adConfig["ASAEnable"] = true;
    //   //adConfig["caid1"] = "";
    //   //adConfig["clipboardEnabled"] = false;
    //   _openinstallFlutterPlugin.configIos(adConfig);
    // }

    _openinstallFlutterPlugin.init(wakeupHandler);

    if (!mounted) return;
    setState(() {});
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  // 唤起为被动回调，无主动调用接口；这里展示最近一次收到的唤起参数，未收到时给出测试指引
  void _showWakeUpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('唤起参数'),
          content: Text(_wakeUpLog.isEmpty
              ? '暂未收到唤起参数。\n\n唤起为被动回调，无需主动调用：请通过 openinstall 控制台“在线测试”，或点击一键拉起链接（scheme / 通用链接）打开 App，拉起参数会自动显示在页面上方。'
              : _wakeUpLog),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('openinstall plugin demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          _buildResultCard('安装参数', _installLog),
          const SizedBox(height: 8),
          _buildResultCard('唤起参数', _wakeUpLog),
          const SizedBox(height: 24),
          _buildSectionTitle('数据获取'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: _showWakeUpDialog,
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('唤起参数'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _openinstallFlutterPlugin.install(installHandler, 10);
                  _showSnack('已发起获取安装参数，结果将显示在上方');
                },
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('getInstall'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // 仅 Android 平台生效
                  _openinstallFlutterPlugin.getInstallCanRetry(
                      installHandler, 3);
                  _showSnack('已发起 getInstallCanRetry（仅 Android 生效）');
                },
                icon: const Icon(Icons.replay_outlined, size: 18),
                label: const Text('getInstallCanRetry'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _openinstallFlutterPlugin.getOpid().then((opid) {
                    setState(() {
                      _opidLog = opid ?? "null";
                    });
                    _showSnack('opid：' + (opid ?? "null"));
                  });
                },
                icon: const Icon(Icons.fingerprint, size: 18),
                label: const Text('getOpid'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('统计上报'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  _openinstallFlutterPlugin.reportRegister();
                  _showSnack('注册统计已上报');
                },
                icon: const Icon(Icons.app_registration, size: 18),
                label: const Text('reportRegister'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _openinstallFlutterPlugin.reportEffectPoint("effect_test", 1);
                  _showSnack('效果点 effect_test 已上报');
                },
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text('reportEffectPoint'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Map<String, String> extraMap = {
                    "systemVersion": Platform.operatingSystemVersion,
                    "flutterVersion": Platform.version
                  };
                  _openinstallFlutterPlugin.reportEffectPoint(
                      "effect_detail", 1, extraMap);
                  _showSnack('效果点明细 effect_detail 已上报');
                },
                icon: const Icon(Icons.analytics, size: 18),
                label: const Text('reportEffectDetail'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _openinstallFlutterPlugin
                      .reportShare("123456", "WechatSession")
                      .then((data) {
                    print("reportShare : " + data.toString());
                    _showSnack('分享上报结果：' + data.toString());
                  });
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('reportShare'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value.trim().isEmpty ? "暂无数据" : value.trim(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Future installHandler(Map<String, Object> data) async {
    print("installHandler : " + data.toString());
    setState(() {
      _installLog = "channel=" +
          data['channelCode'].toString() +
          ", data=" +
          data['bindData'].toString() +
          ", shouldRetry=" +
          data['shouldRetry'].toString();
    });
  }

  Future wakeupHandler(Map<String, Object> data) async {
    print("wakeupHandler : " + data.toString());
    setState(() {
      _wakeUpLog = "channel=" +
          data['channelCode'].toString() +
          ", data=" +
          data['bindData'].toString();
    });
  }

  Future logHandler(Map<String, Object> data) async {
    print("logHandler : " + data.toString());
  }
}

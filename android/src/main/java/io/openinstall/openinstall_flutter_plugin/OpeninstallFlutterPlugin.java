package io.openinstall.openinstall_flutter_plugin;

import android.app.Activity;
import android.content.Context;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallAdapter;
import com.fm.openinstall.listener.AppWakeUpAdapter;
import com.fm.openinstall.model.AppData;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * OpeninstallFlutterPlugin
 */
public class OpeninstallFlutterPlugin implements MethodCallHandler {

    private static MethodChannel channel = null;
    private static AppData dataHolder = null;
    private static boolean LISTEN = false;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), "openinstall_flutter_plugin");
        channel.setMethodCallHandler(new OpeninstallFlutterPlugin());

        registrar.addNewIntentListener(new PluginRegistry.NewIntentListener() {
            @java.lang.Override
            public boolean onNewIntent(android.content.Intent intent) {
                OpenInstall.getWakeUp(intent, wakeUpAdapter);
                return true;
            }
        });

        Context context = registrar.context();
        if (context != null) {
            OpenInstall.init(context);
        }
        Activity activity = registrar.activity();
        if (activity != null) {
            OpenInstall.getWakeUp(activity.getIntent(), wakeUpAdapter);
        }
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getInstall")) {
            Integer seconds = call.argument("seconds");
            OpenInstall.getInstall(new AppInstallAdapter() {
                @Override
                public void onInstall(AppData appData) {
                    channel.invokeMethod("onInstallNotification", data2Map(appData));
                }
            }, seconds == null ? 0 : seconds);
            result.success("getInstall success, wait callback");
        } else if (call.method.equals("reportRegister")) {
            OpenInstall.reportRegister();
            result.success("reportRegister success");
        } else if (call.method.equals("reportEffectPoint")) {
            String pointId = call.argument("pointId");
            Integer pointValue = call.argument("pointValue");
            OpenInstall.reportEffectPoint(pointId, pointValue == null ? 0 : pointValue);
            result.success("reportEffectPoint success");
        } else if (call.method.equals("registerWakeup")) {
            LISTEN = true;
            if (dataHolder != null) {
                channel.invokeMethod("onWakeupNotification", data2Map(dataHolder));
                dataHolder = null;
            }
            result.success("registerWakeup success");
        } else {
            result.notImplemented();
        }
    }

    private static AppWakeUpAdapter wakeUpAdapter = new AppWakeUpAdapter() {
        @Override
        public void onWakeUp(AppData appData) {
            if (LISTEN) {
                channel.invokeMethod("onWakeupNotification", data2Map(appData));
                dataHolder = null;
            } else {
                dataHolder = appData;
            }
        }
    };

    private static Map<String, String> data2Map(AppData data) {
        Map<String, String> result = new HashMap<>();
        result.put("channelCode", data.getChannel());
        result.put("bindData", data.getData());
        return result;
    }

}

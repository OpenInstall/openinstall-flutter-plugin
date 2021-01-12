package io.openinstall.openinstall_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.fm.openinstall.Configuration;
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

    private static final String TAG = "OpeninstallPlugin";

    private static MethodChannel _channel = null;
    private static Registrar _registrar = null;
    private static Intent intentHolder = null;
    private static volatile boolean INIT = false;
    private static Configuration configuration = null;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        _registrar = registrar;
        _channel = new MethodChannel(registrar.messenger(), "openinstall_flutter_plugin");
        _channel.setMethodCallHandler(new OpeninstallFlutterPlugin());

        registrar.addNewIntentListener(new PluginRegistry.NewIntentListener() {
            @Override
            public boolean onNewIntent(android.content.Intent intent) {
                if (INIT) {
                    OpenInstall.getWakeUp(intent, wakeUpAdapter);
                } else {
                    intentHolder = intent;
                }
                return false;
            }
        });

    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.d(TAG, "call method " + call.method);
        if (call.method.equals("getInstall")) {
            Integer seconds = call.argument("seconds");
            OpenInstall.getInstall(new AppInstallAdapter() {
                @Override
                public void onInstall(AppData appData) {
                    _channel.invokeMethod("onInstallNotification", data2Map(appData));
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
            Log.d(TAG, "Android registerWakeup Deprecated");
            result.success("registerWakeup Deprecated");
        } else if (call.method.equals("init")) {
            init();
            result.success("init success");
        } else if (call.method.equals("initWithPermission")) {
            Activity activity = _registrar.activity();
            if (activity != null) {
                initWithPermission(activity);
                result.success("initWithPermission success, wait request permission");
            } else {
                Log.d(TAG, "Activity is null, can't call initWithPermission");
                init();
                result.success("init success");
            }
        } else if (call.method.equals("config")) {
            String oaid = call.argument("oaid");
            String gaid = call.argument("gaid");
            Boolean adEnabled = call.argument("adEnabled");
            config(adEnabled == null ? false : adEnabled, oaid, gaid);
            result.success("config success");
        } else {
            result.notImplemented();
        }
    }

    private void config(boolean adEnabled, String oaid, String gaid) {
        Configuration.Builder builder = new Configuration.Builder();
        builder.adEnabled(adEnabled);
        builder.oaid(oaid);
        builder.gaid(gaid);
        Log.d(TAG, String.format("config adEnabled=%b, oaid=%s, gaid=%s",
                adEnabled, oaid == null ? "NULL" : oaid, gaid == null ? "NULL" : gaid));
        configuration = builder.build();
    }

    private void init() {
        Context context = _registrar.context();
        if (context != null) {
            OpenInstall.init(context, configuration);
            INIT = true;
            if (intentHolder == null) {
                Activity activity = _registrar.activity();
                if (activity != null) {
                    OpenInstall.getWakeUp(activity.getIntent(), wakeUpAdapter);
                }
            } else {
                OpenInstall.getWakeUp(intentHolder, wakeUpAdapter);
            }
        } else {
            Log.d(TAG, "Context is null, can not init OpenInstall");
        }
    }

    private void initWithPermission(final Activity activity) {
        if (activity == null) {
            return;
        }
        _registrar.addRequestPermissionsResultListener(new PluginRegistry.RequestPermissionsResultListener() {
            @Override
            public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
                OpenInstall.onRequestPermissionsResult(requestCode, permissions, grantResults);
                return false;
            }
        });
        OpenInstall.initWithPermission(activity, configuration, new Runnable() {
            @Override
            public void run() {
                INIT = true;
                if (intentHolder == null) {
                    OpenInstall.getWakeUp(activity.getIntent(), wakeUpAdapter);
                } else {
                    OpenInstall.getWakeUp(intentHolder, wakeUpAdapter);
                }
            }
        });

    }

    private static AppWakeUpAdapter wakeUpAdapter = new AppWakeUpAdapter() {
        @Override
        public void onWakeUp(AppData appData) {
            _channel.invokeMethod("onWakeupNotification", data2Map(appData));
            intentHolder = null;
        }
    };

    private static Map<String, String> data2Map(AppData data) {
        Map<String, String> result = new HashMap<>();
        result.put("channelCode", data.getChannel());
        result.put("bindData", data.getData());
        return result;
    }

}

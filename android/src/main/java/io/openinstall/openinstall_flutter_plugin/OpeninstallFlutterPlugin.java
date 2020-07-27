package io.openinstall.openinstall_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallAdapter;
import com.fm.openinstall.listener.AppWakeUpAdapter;
import com.fm.openinstall.model.AppData;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

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
    private static AppData dataHolder = null;
    private static boolean LISTEN = false;
    private CountDownLatch countDownLatch = new CountDownLatch(1);

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
                OpenInstall.getWakeUp(intent, wakeUpAdapter);
                return true;
            }
        });

    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.d(TAG, "call method " + call.method);
        if (call.method.equals("getInstall")) {
            Integer seconds = call.argument("seconds");
            waitInit();
            OpenInstall.getInstall(new AppInstallAdapter() {
                @Override
                public void onInstall(AppData appData) {
                    _channel.invokeMethod("onInstallNotification", data2Map(appData));
                }
            }, seconds == null ? 0 : seconds);
            result.success("getInstall success, wait callback");
        } else if (call.method.equals("reportRegister")) {
            waitInit();
            OpenInstall.reportRegister();
            result.success("reportRegister success");
        } else if (call.method.equals("reportEffectPoint")) {
            String pointId = call.argument("pointId");
            Integer pointValue = call.argument("pointValue");
            waitInit();
            OpenInstall.reportEffectPoint(pointId, pointValue == null ? 0 : pointValue);
            result.success("reportEffectPoint success");
        } else if (call.method.equals("registerWakeup")) {
            LISTEN = true;
            if (dataHolder != null) {
                _channel.invokeMethod("onWakeupNotification", data2Map(dataHolder));
                dataHolder = null;
            }
            result.success("registerWakeup success");
        } else if (call.method.equals("init")) {
            init();
        } else if (call.method.equals("initWithPermission")) {
            Activity activity = _registrar.activity();
            if (activity != null) {
                initWithPermission(activity);
            } else {
                init();
            }
        } else {
            result.notImplemented();
        }
    }

    private void init() {
        Context context = _registrar.context();
        if (context != null) {
            OpenInstall.init(context);
            countDownLatch.countDown();
            Activity activity = _registrar.activity();
            if (activity != null) {
                OpenInstall.getWakeUp(activity.getIntent(), wakeUpAdapter);
            }
        } else {
            Log.d(TAG, "Context is null, can not init OpenInstall");
        }
    }

    private void initWithPermission(final Activity activity) {
        if (activity == null) return;
        _registrar.addRequestPermissionsResultListener(new PluginRegistry.RequestPermissionsResultListener() {
            @Override
            public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
                OpenInstall.onRequestPermissionsResult(requestCode, permissions, grantResults);
                return false;
            }
        });
        OpenInstall.initWithPermission(activity, new Runnable() {
            @Override
            public void run() {
                countDownLatch.countDown();
                OpenInstall.getWakeUp(activity.getIntent(), wakeUpAdapter);
            }
        });

    }

    private static AppWakeUpAdapter wakeUpAdapter = new AppWakeUpAdapter() {
        @Override
        public void onWakeUp(AppData appData) {
            if (LISTEN) {
                _channel.invokeMethod("onWakeupNotification", data2Map(appData));
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

    private void waitInit() {
        try {
            countDownLatch.await(10, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

}

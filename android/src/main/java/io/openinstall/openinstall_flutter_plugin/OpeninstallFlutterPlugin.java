package io.openinstall.openinstall_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.fm.openinstall.Configuration;
import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallAdapter;
import com.fm.openinstall.listener.AppWakeUpAdapter;
import com.fm.openinstall.model.AppData;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * OpeninstallFlutterPlugin
 */
public class OpeninstallFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private static final String TAG = "OpenInstallPlugin";

    private static final String METHOD_CONFIG = "config";
    private static final String METHOD_INIT = "init";
    private static final String METHOD_INIT_PERMISSION = "initWithPermission";
    private static final String METHOD_WAKEUP = "registerWakeup";
    private static final String METHOD_INSTALL = "getInstall";
    private static final String METHOD_REGISTER = "reportRegister";
    private static final String METHOD_EFFECT_POINT = "reportEffectPoint";

    private static final String METHOD_WAKEUP_NOTIFICATION = "onWakeupNotification";
    private static final String METHOD_INSTALL_NOTIFICATION = "onInstallNotification";

    private MethodChannel channel = null;
    private ActivityPluginBinding activityPluginBinding;
    private FlutterPluginBinding flutterPluginBinding;
    private Intent intentHolder = null;
    private volatile boolean initialized = false;
    private Configuration configuration = null;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        flutterPluginBinding = binding;
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "openinstall_flutter_plugin");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        activityPluginBinding.addOnNewIntentListener(newIntentListener);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        Log.d(TAG, "call method " + call.method);
        if (METHOD_CONFIG.equalsIgnoreCase(call.method)) {
            String oaid = call.argument("oaid");
            String gaid = call.argument("gaid");
            Boolean adEnabled = call.argument("adEnabled");
            config(adEnabled == null ? false : adEnabled, oaid, gaid);
            result.success("OK");
        } else if (METHOD_INIT.equalsIgnoreCase(call.method)) {
            init();
            result.success("OK");
        } else if (METHOD_INIT_PERMISSION.equalsIgnoreCase(call.method)) {
            Activity activity = activityPluginBinding.getActivity();
            if (activity != null) {
                initWithPermission(activity);
            } else {
                Log.d(TAG, "Activity is null, can't call initWithPermission");
                init();
            }
            result.success("OK");
        } else if (METHOD_WAKEUP.equalsIgnoreCase(call.method)) {
            result.success("OK");
        } else if (METHOD_INSTALL.equalsIgnoreCase(call.method)) {
            Integer seconds = call.argument("seconds");
            OpenInstall.getInstall(new AppInstallAdapter() {
                @Override
                public void onInstall(AppData appData) {
                    channel.invokeMethod(METHOD_INSTALL_NOTIFICATION, data2Map(appData));
                }
            }, seconds == null ? 0 : seconds);
            result.success("OK");
        } else if (METHOD_REGISTER.equalsIgnoreCase(call.method)) {
            OpenInstall.reportRegister();
            result.success("OK");
        } else if (METHOD_EFFECT_POINT.equalsIgnoreCase(call.method)) {
            String pointId = call.argument("pointId");
            Integer pointValue = call.argument("pointValue");
            OpenInstall.reportEffectPoint(pointId, pointValue == null ? 0 : pointValue);
            result.success("OK");
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
        Context context = flutterPluginBinding.getApplicationContext();
        if (context != null) {
            OpenInstall.init(context, configuration);
            initialized = true;
            if (intentHolder == null) {
                Activity activity = activityPluginBinding.getActivity();
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
        activityPluginBinding.addRequestPermissionsResultListener(permissionsResultListener);
        OpenInstall.initWithPermission(activity, configuration, new Runnable() {
            @Override
            public void run() {
                activityPluginBinding.removeRequestPermissionsResultListener(permissionsResultListener);
                initialized = true;
                if (intentHolder == null) {
                    OpenInstall.getWakeUp(activity.getIntent(), wakeUpAdapter);
                } else {
                    OpenInstall.getWakeUp(intentHolder, wakeUpAdapter);
                }
            }
        });

    }

    private final PluginRegistry.NewIntentListener newIntentListener =
            new PluginRegistry.NewIntentListener() {
                @Override
                public boolean onNewIntent(Intent intent) {
                    if (initialized) {
                        OpenInstall.getWakeUp(intent, wakeUpAdapter);
                    } else {
                        intentHolder = intent;
                    }
                    return false;
                }
            };

    private final AppWakeUpAdapter wakeUpAdapter = new AppWakeUpAdapter() {
        @Override
        public void onWakeUp(AppData appData) {
            channel.invokeMethod(METHOD_WAKEUP_NOTIFICATION, data2Map(appData));
            intentHolder = null;
        }
    };

    private final PluginRegistry.RequestPermissionsResultListener permissionsResultListener =
            new PluginRegistry.RequestPermissionsResultListener() {
                @Override
                public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
                    OpenInstall.onRequestPermissionsResult(requestCode, permissions, grantResults);
                    return false;
                }
            };

    private static Map<String, String> data2Map(AppData data) {
        Map<String, String> result = new HashMap<>();
        result.put("channelCode", data.getChannel());
        result.put("bindData", data.getData());
        return result;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}

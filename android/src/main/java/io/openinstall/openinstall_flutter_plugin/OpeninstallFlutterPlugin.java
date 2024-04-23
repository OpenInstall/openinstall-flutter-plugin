package io.openinstall.openinstall_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fm.openinstall.Configuration;
import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallListener;
import com.fm.openinstall.listener.AppInstallRetryAdapter;
import com.fm.openinstall.listener.AppWakeUpAdapter;
import com.fm.openinstall.listener.AppWakeUpListener;
import com.fm.openinstall.listener.ResultCallback;
import com.fm.openinstall.model.AppData;
import com.fm.openinstall.model.Error;

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
public class OpeninstallFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener {

    private static final String TAG = "OpenInstallPlugin";
    @Deprecated
    private static final String METHOD_WAKEUP = "registerWakeup";

    private static final String METHOD_DEBUG = "setDebug";
    private static final String METHOD_CONFIG = "config";
    private static final String METHOD_CLIPBOARD_ENABLED = "clipBoardEnabled";
    private static final String METHOD_INIT = "init";
    private static final String METHOD_INSTALL_RETRY = "getInstallCanRetry";
    private static final String METHOD_INSTALL = "getInstall";
    private static final String METHOD_REGISTER = "reportRegister";
    private static final String METHOD_EFFECT_POINT = "reportEffectPoint";
    private static final String METHOD_SHARE = "reportShare";
    private static final String METHOD_OPID = "getOpid";
    private static final String METHOD_CHANNEL = "setChannel";

    private static final String METHOD_WAKEUP_NOTIFICATION = "onWakeupNotification";
    private static final String METHOD_INSTALL_NOTIFICATION = "onInstallNotification";

    private MethodChannel channel = null;
    private ActivityPluginBinding activityPluginBinding;
    private FlutterPluginBinding flutterPluginBinding;
    private Intent intentHolder = null;
    private volatile boolean initialized = false;
    private Configuration configuration = null;

    private boolean alwaysCallback = false;
    private boolean debuggable = true;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        flutterPluginBinding = binding;
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "openinstall_flutter_plugin");
        channel.setMethodCallHandler(this);
        OpenInstall.preInit(flutterPluginBinding.getApplicationContext());
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;

        binding.addOnNewIntentListener(this);
        wakeup(binding.getActivity().getIntent());
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        binding.addOnNewIntentListener(this);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull final Result result) {
        debugLog("invoke " + call.method);
        if (METHOD_DEBUG.equalsIgnoreCase(call.method)) {
            Boolean enabled = call.argument("enabled");
            debuggable = enabled == null ? true : enabled;
            OpenInstall.setDebug(debuggable);
            result.success("OK");
        } else if (METHOD_CONFIG.equalsIgnoreCase(call.method)) {
            config(call);
            result.success("OK");
        } else if (METHOD_CLIPBOARD_ENABLED.equalsIgnoreCase(call.method)) {
            Boolean enabled = call.argument("enabled");
            OpenInstall.clipBoardEnabled(enabled == null ? true : enabled);
            result.success("OK");
        } else if (METHOD_INIT.equalsIgnoreCase(call.method)) {
            Boolean box = call.argument("alwaysCallback");
            alwaysCallback = box == null ? false : box;
            init();
            result.success("OK");
        } else if (METHOD_WAKEUP.equalsIgnoreCase(call.method)) {
            // iOS 使用此接口初始化，继续保留
            result.success("OK");
        } else if (METHOD_INSTALL.equalsIgnoreCase(call.method)) {
            Integer seconds = call.argument("seconds");
            OpenInstall.getInstall(new AppInstallListener() {
                @Override
                public void onInstallFinish(AppData appData, Error error) {
                    Map<String, Object> data = data2Map(appData);
                    boolean shouldRetry = error != null && error.shouldRetry();
                    data.put("shouldRetry", shouldRetry);
                    if (error != null) {
                        data.put("message", error.getErrorMsg());
                    }
                    channel.invokeMethod(METHOD_INSTALL_NOTIFICATION, data);
                }
            }, seconds == null ? 0 : seconds);
            result.success("OK");
        } else if (METHOD_INSTALL_RETRY.equalsIgnoreCase(call.method)) {
            Integer seconds = call.argument("seconds");
            OpenInstall.getInstallCanRetry(new AppInstallRetryAdapter() {
                @Override
                public void onInstall(AppData appData, boolean shouldRetry) {
                    Map<String, Object> data = data2Map(appData);
                    data.put("retry", String.valueOf(shouldRetry)); // 2.4.0 之前的版本返回
                    data.put("shouldRetry", shouldRetry);  // 以后保存统一
                    channel.invokeMethod(METHOD_INSTALL_NOTIFICATION, data);
                }
            }, seconds == null ? 0 : seconds);
            result.success("OK");
        } else if (METHOD_REGISTER.equalsIgnoreCase(call.method)) {
            OpenInstall.reportRegister();
            result.success("OK");
        } else if (METHOD_EFFECT_POINT.equalsIgnoreCase(call.method)) {
            String pointId = call.argument("pointId");
            Integer pointValue = call.argument("pointValue");
            if (TextUtils.isEmpty(pointId) || pointValue == null) {
                Log.w(TAG, "pointId is empty or pointValue is null");
//                result.error("ERROR", "pointId is empty or pointValue is null", null);
            } else {
                Map<String, String> extraMap = call.argument("extras");
                OpenInstall.reportEffectPoint(pointId, pointValue, extraMap);
            }
            result.success("OK");
        } else if (METHOD_SHARE.equalsIgnoreCase(call.method)) {
            String shareCode = call.argument("shareCode");
            String sharePlatform = call.argument("platform");
            final Map<String, Object> data = new HashMap<>();
            if (TextUtils.isEmpty(shareCode) || TextUtils.isEmpty(sharePlatform)) {
                data.put("message", "shareCode or platform is empty");
                data.put("shouldRetry", false);
                result.success(data);
            } else {
                OpenInstall.reportShare(shareCode, sharePlatform, new ResultCallback<Void>() {
                    @Override
                    public void onResult(@Nullable Void v, @Nullable Error error) {
                        boolean shouldRetry = error != null && error.shouldRetry();
                        data.put("shouldRetry", shouldRetry);
                        if (error != null) {
                            data.put("message", error.getErrorMsg());
                        }
                        result.success(data);
                    }
                });
            }
        } else if (METHOD_OPID.equalsIgnoreCase(call.method)) {
            String opid = OpenInstall.getOpid();
            result.success(opid);
        } else if (METHOD_CHANNEL.equalsIgnoreCase(call.method)) {
            String channelCode = call.argument("channelCode");
            OpenInstall.setChannel(channelCode);
            result.success("OK");
        } else {
            result.notImplemented();
        }
    }

    private void config(MethodCall call) {

        Configuration.Builder builder = new Configuration.Builder();

        if (call.hasArgument("androidId")) {
            String androidId = call.argument("androidId");
            builder.androidId(androidId);
        }
        if (call.hasArgument("serialNumber")) {
            String serialNumber = call.argument("serialNumber");
            builder.serialNumber(serialNumber);
        }
        if (call.hasArgument("adEnabled")) {
            Boolean adEnabled = call.argument("adEnabled");
            builder.adEnabled(checkBoolean(adEnabled));
        }
        if (call.hasArgument("oaid")) {
            String oaid = call.argument("oaid");
            builder.oaid(oaid);
        }
        if (call.hasArgument("gaid")) {
            String gaid = call.argument("gaid");
            builder.gaid(gaid);
        }
        if (call.hasArgument("imeiDisabled")) {
            Boolean imeiDisabled = call.argument("imeiDisabled");
            if (checkBoolean(imeiDisabled)) {
                builder.imeiDisabled();
            }
        }
        if (call.hasArgument("imei")) {
            String imei = call.argument("imei");
            builder.imei(imei);
        }
        if (call.hasArgument("macDisabled")) {
            Boolean macDisabled = call.argument("macDisabled");
            if (checkBoolean(macDisabled)) {
                builder.macDisabled();
            }
        }
        if (call.hasArgument("mac")) {
            String macAddress = call.argument("mac");
            builder.macAddress(macAddress);
        }

        configuration = builder.build();
//        debugLog(String.format("Configuration: adEnabled=%s, oaid=%s, gaid=%s, macDisabled=%s, imeiDisabled=%s, "
//                        + "androidId=%s, serialNumber=%s, imei=%s, mac=%s",
//                configuration.isAdEnabled(), configuration.getOaid(), configuration.getGaid(),
//                configuration.isMacDisabled(), configuration.isImeiDisabled(),
//                configuration.getAndroidId(), configuration.getSerialNumber(),
//                configuration.getImei(), configuration.getMacAddress()));

    }

    private boolean checkBoolean(Boolean bool) {
        if (bool == null) return false;
        return bool;
    }

    private void init() {
        Context context = flutterPluginBinding.getApplicationContext();
        OpenInstall.init(context, configuration);
        initialized = true;
        if (intentHolder != null) {
            wakeup(intentHolder);
            intentHolder = null;
        }
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        debugLog("onNewIntent");
        wakeup(intent);
        return false;
    }


    private void wakeup(Intent intent) {
        if (initialized) {
            debugLog("getWakeUp : alwaysCallback=" + alwaysCallback);
            if (alwaysCallback) {
                OpenInstall.getWakeUpAlwaysCallback(intent, new AppWakeUpListener() {
                    @Override
                    public void onWakeUpFinish(AppData appData, Error error) {
                        if (error != null) { // 可忽略，仅调试使用
                            debugLog("getWakeUpAlwaysCallback : " + error.getErrorMsg());
                        }
                        channel.invokeMethod(METHOD_WAKEUP_NOTIFICATION, data2Map(appData));
                    }
                });
            } else {
                OpenInstall.getWakeUp(intent, new AppWakeUpAdapter() {
                    @Override
                    public void onWakeUp(AppData appData) {
                        channel.invokeMethod(METHOD_WAKEUP_NOTIFICATION, data2Map(appData));
                    }
                });
            }
        } else {
            intentHolder = intent;
        }
    }

    private static Map<String, Object> data2Map(AppData data) {
        Map<String, Object> result = new HashMap<>();
        if (data != null) {
            result.put("channelCode", data.getChannel());
            result.put("bindData", data.getData());
        }
        return result;
    }

    private void debugLog(String message) {
        if (debuggable) {
            Log.d(TAG, message);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}

package io.openinstall.openinstall_flutter_plugin_example;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;

public class MainApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        FlutterEngineCache.getInstance().put("cache_engine", new FlutterEngine(this));
    }
}

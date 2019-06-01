package com.gd.pedometer.pedometer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.util.Log;

/** PedometerPlugin */
public class PedometerPlugin implements MethodCallHandler {

    private SensorManager sensorManager;
    private Sensor stepCouter;         //计步总数传感器
    private SensorEventListener stepCounterListener; // 监听器
    private float stepCount = 0.0f; //步数
    private Activity activity;

    private PedometerPlugin(Activity activity) {
        this.activity = activity;
    }

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "gd_flutter_sdk_pedometer");
        Log.e("Counter-SDK","init method");
        PedometerPlugin plugin = new PedometerPlugin(registrar.activity());
        channel.setMethodCallHandler(plugin);
     }

    private String registerSensor() {
        // 注册传感器监听器
        PackageManager pm = this.activity.getPackageManager();
        if(pm.hasSystemFeature(PackageManager.FEATURE_SENSOR_STEP_COUNTER)) {
            Log.e("Counter-SDK","Counter is support");
            sensorManager.registerListener(stepCounterListener, stepCouter, SensorManager.SENSOR_DELAY_FASTEST);
            return "support";
        } else {
            Log.e("Counter-SDK","Counter is not support");
            return "no support";
        }
    }

    private String unregisterSensor() {
        PackageManager pm = this.activity.getPackageManager();
        if(pm.hasSystemFeature(PackageManager.FEATURE_SENSOR_STEP_COUNTER)) {
            sensorManager.unregisterListener(stepCounterListener);
            return "support";
        }
        return "no support";
    }

    private String setupStepCounter() {
        Log.e("Counter-SDK","setupStepCounter");
        sensorManager = (SensorManager)this.activity.getSystemService(this.activity.SENSOR_SERVICE);
        stepCouter = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER);
        stepCounterListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                stepCount = (float) event.values[0];
                Log.e("Counter-SensorChanged", event.values[0] + "---" + event.accuracy + "---" + event.timestamp);
            }
            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {
                Log.e("Counter-Accuracy",sensor.getName()+"---"+accuracy);
            }
        };
        return registerSensor();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
     } else if(call.method.equals("initStepCounter")) {
        String rtn = setupStepCounter();
        result.success(rtn);
    } else if(call.method.equals("getTodayStepCount")) {
        String stepString=String.format("%f", stepCount);
        result.success(stepString);
    } else {
        result.notImplemented();
    }
  }
}

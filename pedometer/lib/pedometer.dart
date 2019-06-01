import 'dart:async';

import 'package:flutter/services.dart';

class Pedometer {
  static const MethodChannel _channel =
      const MethodChannel('gd_flutter_sdk_pedometer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get initStepCounter async {
    final String result = await _channel.invokeMethod("initStepCounter");
    return result;
  }

  static Future<String> get todayStepCount async {
    final String stepCount = await _channel.invokeMethod("getTodayStepCount");
    return stepCount;
  }
}

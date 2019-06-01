import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _todayStep = '0.0';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    setupStepCounter();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Pedometer.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> setupStepCounter() async {
    String result = "";
    try {
      result = await Pedometer.initStepCounter;
    } on PlatformException {
      result = 'Failed to get todayStepCount.';
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getTodayStep() async {
    String todayStep;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      todayStep = await Pedometer.todayStepCount;
    } on PlatformException {
      todayStep = '0.0';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _todayStep = todayStep;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('step:$_todayStep'),
        ),
        body: Center(
          child: RaisedButton(
                    color: Color.fromRGBO(128, 195, 255, 1),
                    child: Text("Get Step Count"),
                    onPressed:  () {
                      setState(() {
                        getTodayStep();
                    });
                  }),
        ),
      ),
    );
  }
}

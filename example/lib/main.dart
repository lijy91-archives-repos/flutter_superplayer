import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_superplayer/flutter_superplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SuperPlayerController _playerController = SuperPlayerController();

  String _sdkVersion = 'Unknown';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String sdkVersion;
    try {
      sdkVersion = await FlutterSuperPlayer.sdkVersion;
    } on PlatformException {
      sdkVersion = 'Failed to get sdk version.';
    }

    if (!mounted) return;

    setState(() {
      _sdkVersion = sdkVersion;
    });
  }

  void _handleClickPlayWithModel(BuildContext context) {
    int appId = 1252463788;
    String fileId = "5285890781763144364";

    SuperPlayerModel superPlayerModel = SuperPlayerModel(
      appId: appId,
      videoId: SuperPlayerVideoId(fileId: fileId),
    );

    _playerController.playWithModel(superPlayerModel);
  }


  void _handleClickRequestPlayMode(BuildContext context) {
    _playerController.requestPlayMode(SuperPlayerConst.PLAYMODE_FLOAT);
  }

  void _addLog(String tag, dynamic data) {
    _logs.add('>>>$tag');
    if (data != null) _logs.add(json.encode(data));
    _logs.add(' ');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 280,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.red),
                ),
                child: SuperPlayerView(
                  controller: _playerController,
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => this._handleClickPlayWithModel(context),
                      child: Text('playWithModel'),
                    ),
                    FlatButton(
                      onPressed: () => this._handleClickRequestPlayMode(context),
                      child: Text('requestPlayMode'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (var log in _logs) Text(log),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

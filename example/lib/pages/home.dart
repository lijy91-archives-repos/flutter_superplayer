import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_superplayer/flutter_superplayer.dart';

const _kControlViewTypes = [kControlViewTypeDefault, kControlViewTypeWithout];

class _ListSection extends StatelessWidget {
  final Widget? title;

  const _ListSection({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                child: title!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ListItem({
    Key? key,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: BoxConstraints(minHeight: 48),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        ),
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Row(
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  child: title!,
                ),
                Expanded(child: Container()),
                if (trailing != null) SizedBox(height: 34, child: trailing),
              ],
            ),
            if (subtitle != null) Container(child: subtitle),
          ],
        ),
      ),
      onTap: this.onTap,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SuperPlayerListener {
  SuperPlayerController _playerController = SuperPlayerController();

  String _sdkVersion = 'Unknown';
  List<String> _logs = [];

  String _controlViewType = _kControlViewTypes.first;

  @override
  void initState() {
    _playerController.addListener(this);
    super.initState();
    initPlatformState();
  }

  SuperPlayerModel get testSuperPlayerModel {
    int appId = 1252463788;
    String fileId = "5285890781763144364";

    SuperPlayerModel superPlayerModel = SuperPlayerModel(
      appId: appId,
      videoId: SuperPlayerVideoId(fileId: fileId),
    );
    return superPlayerModel;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String sdkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      sdkVersion = await FlutterSuperPlayer.sdkVersion;
    } on PlatformException {
      sdkVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sdkVersion = sdkVersion;
    });
  }

  void _addLog(String method, dynamic data) {
    _logs.add('>>>$method');
    if (data != null) {
      _logs.add(data is Map ? json.encode(data) : data);
    }
    _logs.add(' ');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  _ListItem(
                    title: Text('SDKVersion: $_sdkVersion'),
                    trailing: GestureDetector(
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        _playerController.resetPlayer();
                        _logs = [];
                        setState(() {});
                      },
                    ),
                  ),
                  Divider(height: 0, indent: 16, endIndent: 16),
                  _ListItem(
                    title: Text('action'),
                    trailing: ToggleButtons(
                      children: <Widget>[
                        Text('play'),
                        Text('pause'),
                        Text('resume'),
                      ],
                      onPressed: (int index) {
                        switch (index) {
                          case 0:
                            _playerController
                                .playWithModel(testSuperPlayerModel);
                            break;
                          case 1:
                            _playerController.pause();
                            break;
                          case 2:
                            _playerController.resume();
                            break;
                        }
                      },
                      isSelected: [false, false, false],
                    ),
                  ),
                  _ListSection(
                    title: Text('Option'),
                  ),
                  _ListItem(
                    title: Text('controlViewType'),
                    trailing: ToggleButtons(
                      children: <Widget>[
                        for (var controlViewType in _kControlViewTypes)
                          Text(controlViewType),
                      ],
                      onPressed: (int index) {
                        _controlViewType = _kControlViewTypes[index];

                        setState(() {});
                      },
                      isSelected: _kControlViewTypes
                          .map((e) => e == _controlViewType)
                          .toList(),
                    ),
                  ),
                  Divider(height: 0, indent: 16, endIndent: 16),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * (9 / 16),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.red),
                    ),
                    child: SuperPlayerView(
                      controller: _playerController,
                      controlViewType: _controlViewType,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
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
    );
  }

  @override
  void onClickFloatCloseBtn() {
    _addLog('onClickFloatCloseBtn', {});
  }

  @override
  void onClickSmallReturnBtn() {
    _addLog('onClickSmallReturnBtn', {});
  }

  @override
  void onFullScreenChange(bool isFullScreen) {
    _addLog('onFullScreenChange', {'isFullScreen': isFullScreen});
  }

  @override
  void onPlayProgressChange(int current, int duration) {
    _addLog('onPlayProgressChange', {'current': current, 'duration': duration});
  }

  @override
  void onPlayStateChange(int playState) {
    _addLog('onPlayStateChange', {'playState': playState});
  }

  @override
  void onStartFloatWindowPlay() {
    _addLog('onStartFloatWindowPlay', {});
  }
}

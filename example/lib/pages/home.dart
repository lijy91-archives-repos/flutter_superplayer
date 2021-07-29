import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_superplayer/flutter_superplayer.dart';
import 'package:preference_list/preference_list.dart';

const _kControlViewTypes = [kControlViewTypeDefault, kControlViewTypeWithout];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SuperPlayerListener {
  SuperPlayerController _playerController = SuperPlayerController();

  String _sdkVersion = 'Unknown';
  List<String> _logs = [];

  String _controlViewType = _kControlViewTypes.first;
  bool _isFullScreen = false;

  @override
  void initState() {
    _playerController.addListener(this);
    super.initState();
    _init();
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

  Future<void> _init() async {
    _sdkVersion = await FlutterSuperPlayer.instance.sdkVersion;

    _playerController.setModel(this.testSuperPlayerModel);

    if (!mounted) return;

    setState(() {});
  }

  void _addLog(String method, dynamic data) {
    _logs.add('>>>$method');
    if (data != null) {
      _logs.add(data is Map ? json.encode(data) : data);
    }
    _logs.add(' ');
    setState(() {});
  }

  Widget _buildSuperPlayerView(BuildContext context) {
    double viewWidth = MediaQuery.of(context).size.width;
    double viewHeight = 212;
    if (_isFullScreen) {
      viewHeight = MediaQuery.of(context).size.height;
    }
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              width: viewWidth,
              height: viewHeight,
              child: SuperPlayerView(
                controller: _playerController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFullScreen ? Colors.black : null,
      appBar: !_isFullScreen
          ? AppBar(
              title: const Text('Plugin example app'),
            )
          : null,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: _buildSuperPlayerView(context),
            ),
            if (!_isFullScreen)
              Expanded(
                child: Column(
                  children: [
                    PreferenceListSection(
                      children: [
                        PreferenceListItem(
                          title: Text('SDKVersion: $_sdkVersion'),
                          accessoryView: GestureDetector(
                            child: Container(
                              color: Theme.of(context).primaryColor,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'RESET',
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
                        PreferenceListItem(
                          title: Text('action'),
                          accessoryView: ToggleButtons(
                            children: <Widget>[
                              Text('play'),
                              Text('pause'),
                              Text('resume'),
                            ],
                            onPressed: (int index) {
                              switch (index) {
                                case 0:
                                  _playerController.play();
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
                      ],
                    ),
                    PreferenceListSection(
                      title: Text('Option'),
                      children: [
                        PreferenceListItem(
                          title: Text('controlViewType'),
                          accessoryView: ToggleButtons(
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
                      ],
                    ),
                    Container(
                      height: 100,
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 20),
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
              )
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

    setState(() {
      _isFullScreen = isFullScreen;
    });
  }

  @override
  void onPlayProgressChange(int current, int duration) {
    _addLog('onPlayProgressChange', {'current': current, 'duration': duration});
  }

  @override
  void onPlayStateChange(int playState) {
    _addLog('onPlayStateChange', {'playState': playState});
  }
}

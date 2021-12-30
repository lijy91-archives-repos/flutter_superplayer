import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './constants.dart';
import './superplayer_const.dart';
import './superplayer_listener.dart';
import './superplayer_model.dart';

const kMethodOnFullScreenChange = 'onFullScreenChange';
const kMethodOnClickFloatCloseBtn = 'onClickFloatCloseBtn';
const kMethodOnClickSmallReturnBtn = 'onClickSmallReturnBtn';
const kMethodOnPlayStateChange = 'onPlayStateChange';
const kMethodOnPlayProgressChange = 'onPlayProgressChange';
const kMethodOnControlViewIsVisibleChange = 'onControlViewIsVisibleChange';

class SuperPlayerController {
  ObserverList<SuperPlayerListener>? _listeners =
      ObserverList<SuperPlayerListener>();
  MethodChannel? _channel;
  EventChannel? _eventChannel;

  SuperPlayerModel? _model;
  bool _isFullScreen = false;

  void _onEvent(dynamic event) {
    String listener = '${event['listener']}';
    String method = '${event['method']}';

    switch (listener) {
      case 'SuperPlayerListener':
        notifyListeners(method, event['data']);
        break;
    }
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return _listeners!.isNotEmpty;
  }

  void addListener(SuperPlayerListener listener) {
    assert(_debugAssertNotDisposed());
    _listeners!.add(listener);
  }

  void removeListener(SuperPlayerListener listener) {
    assert(_debugAssertNotDisposed());
    _listeners!.remove(listener);
  }

  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  void notifyListeners(String? method, [dynamic data]) {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      final List<SuperPlayerListener> localListeners =
          List<SuperPlayerListener>.from(_listeners!);
      for (final SuperPlayerListener listener in localListeners) {
        try {
          if (_listeners!.contains(listener)) {
            switch (method) {
              case kMethodOnFullScreenChange:
                listener.onFullScreenChange(data['isFullScreen']);
                break;
              case kMethodOnClickFloatCloseBtn:
                listener.onClickFloatCloseBtn();
                break;
              case kMethodOnClickSmallReturnBtn:
                listener.onClickSmallReturnBtn();
                break;
              case kMethodOnPlayStateChange:
                listener.onPlayStateChange(data['playState']);
                break;
              case kMethodOnPlayProgressChange:
                listener.onPlayProgressChange(
                  data['current'],
                  data['duration'],
                );
                break;
              case kMethodOnControlViewIsVisibleChange:
                listener.onControlViewIsVisibleChange(data['isVisible']);
                break;
            }
          }
        } catch (exception) {}
      }
    }
  }

  void initWithViewId(int viewId) {
    _channel = MethodChannel('${kSuperPlayerViewChannelName}_$viewId');
    _eventChannel = EventChannel('${kSuperPlayerViewEventChannelName}_$viewId');

    _eventChannel!.receiveBroadcastStream().listen(_onEvent);
  }

  Future<SuperPlayerModel> getModel() async {
    final Map<dynamic, dynamic> resultData =
        await _channel!.invokeMethod('getModel', {});

    if ((_model?.multiURLs ?? []).isEmpty) {
      _model!.multiURLs = (resultData['multiURLs'] as List)
          .map((e) => SuperPlayerURL(
                qualityName: e['qualityName'],
                url: e['url'],
              ))
          .toList();
    }

    print(resultData);
    print(_model!.toJson());
    return _model!;
  }

  void setModel(SuperPlayerModel model) {
    _model = model;
  }

  Future<bool> isFullScreen() async {
    return _isFullScreen;
  }

  Future<void> setFullScreen(bool isFullScreen) async {
    _isFullScreen = isFullScreen;
    notifyListeners(kMethodOnFullScreenChange, {'isFullScreen': _isFullScreen});

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  Future<int> getPlayMode() async {
    return await _channel!.invokeMethod('getPlayMode', {});
  }

  Future<int> getPlayState() async {
    return await _channel!.invokeMethod('getPlayState', {});
  }

  Future<num> getPlayRate() async {
    return await _channel!.invokeMethod('getPlayRate', {});
  }

  void setCoverImage(String coverImageUrl) {
    if (Platform.isAndroid) return;

    final Map<String, dynamic> arguments = {
      'coverImageUrl': coverImageUrl,
    };
    _channel!.invokeMethod('setCoverImage', arguments);
  }

  void setPlayRate(num playRate) {
    final Map<String, dynamic> arguments = {
      'playRate': playRate,
    };
    _channel!.invokeMethod('setPlayRate', arguments);
  }

  Future<SuperPlayerURL?> getVideoQuality() async {
    final Map<dynamic, dynamic>? resultData =
        await _channel!.invokeMethod('getVideoQuality', {});

    if (resultData != null) {
      SuperPlayerURL superPlayerURL = SuperPlayerURL(
        qualityName: resultData['qualityName'],
        url: resultData['url'],
      );

      return superPlayerURL;
    }
    return null;
  }

  void setVideoQuality(SuperPlayerURL superPlayerURL) {
    _channel!.invokeMethod('setVideoQuality', superPlayerURL.toJson());
  }

  void resetPlayer() {
    _channel!.invokeMethod('resetPlayer');
  }

  void setStartTime(int startTime) {
    _channel!.invokeMethod(
      'setStartTime',
      {'startTime': startTime},
    );
  }

  void playWithModel(final SuperPlayerModel model) {
    this.setModel(model);
    this.play();
  }

  void play() {
    if (_model != null) {
      _channel!.invokeMethod('playWithModel', _model!.toJson());
    }
  }

  void pause() {
    _channel!.invokeMethod('pause');
  }

  void resume() {
    _channel!.invokeMethod('resume');
  }

  void release() {
    _channel!.invokeMethod('release');
  }

  void seekTo(int time) {
    final Map<String, dynamic> arguments = {
      'time': time,
    };
    _channel!.invokeMethod('seekTo', arguments);
  }

  void setLoop(bool isLoop) {
    final Map<String, dynamic> arguments = {
      'isLoop': isLoop,
    };
    _channel!.invokeMethod('setLoop', arguments);
  }
}

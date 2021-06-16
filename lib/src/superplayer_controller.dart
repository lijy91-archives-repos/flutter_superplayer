import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './constants.dart';
import './superplayer_const.dart';
import './superplayer_listener.dart';
import './superplayer_model.dart';
// import './superplayer_view.dart';

class SuperPlayerController {
  ObserverList<SuperPlayerListener> _listeners =
      ObserverList<SuperPlayerListener>();
  MethodChannel _channel;
  EventChannel _eventChannel;

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
    return _listeners.isNotEmpty;
  }

  void addListener(SuperPlayerListener listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  void removeListener(SuperPlayerListener listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  void notifyListeners(String method, dynamic data) {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      final List<SuperPlayerListener> localListeners =
          List<SuperPlayerListener>.from(_listeners);
      for (final SuperPlayerListener listener in localListeners) {
        try {
          if (_listeners.contains(listener)) {
            switch (method) {
              case 'onFullScreenChange':
                listener.onFullScreenChange(data['isFullScreen']);
                break;
              case 'onClickFloatCloseBtn':
                listener.onClickFloatCloseBtn();
                break;
              case 'onClickSmallReturnBtn':
                listener.onClickSmallReturnBtn();
                break;
              case 'onStartFloatWindowPlay':
                listener.onStartFloatWindowPlay();
                break;
              case 'onPlayStateChange':
                listener.onPlayStateChange(data['playState']);
                break;
              case 'onPlayProgressChange':
                listener.onPlayProgressChange(
                  data['current'],
                  data['duration'],
                );
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

    _eventChannel.receiveBroadcastStream().listen(_onEvent);
  }

  Future<int> getPlayMode() async {
    return await _channel.invokeMethod('getPlayMode', {});
  }

  Future<int> getPlayState() async {
    return await _channel.invokeMethod('getPlayState', {});
  }

  Future<num> getPlayRate() async {
    return await _channel.invokeMethod('getPlayRate', {});
  }

  void setControlViewType(String controlViewType) {
    _channel.invokeMethod('setControlViewType', {
      'controlViewType': controlViewType,
    });
  }

  void setTitle(String title) {
    _channel.invokeMethod('setTitle', {
      'title': title,
    });
  }

  void setCoverImage(String coverImageUrl) {
    _channel.invokeMethod(
      'setCoverImage',
      {'coverImageUrl': coverImageUrl},
    );
  }

  void setPlayRate(num playRate) {
    _channel.invokeMethod('setPlayRate', {'playRate': playRate});
  }

  void resetPlayer() {
    _channel.invokeMethod('resetPlayer');
  }

  void requestPlayMode(int playMode) {
    _channel.invokeMethod('requestPlayMode', {
      'playMode': playMode,
    });
  }

  void playWithModel(final SuperPlayerModel model) {
    _channel.invokeMethod('playWithModel', model.toJson());
  }

  void pause() {
    _channel.invokeMethod('pause');
  }

  void resume() {
    _channel.invokeMethod('resume');
  }

  void release() {
    _channel.invokeMethod('release');
  }

  void seekTo(int time) {
    _channel.invokeMethod('seekTo', {
      'time': time,
    });
  }

  void setLoop(bool isLoop) {
    _channel.invokeMethod('setLoop', {
      'isLoop': isLoop,
    });
  }

  void uiHideDanmu() {
    _channel.invokeMethod('uiHideDanmu');
  }

  void uiHideReplay() {
    _channel.invokeMethod('uiHideReplay');
  }
}

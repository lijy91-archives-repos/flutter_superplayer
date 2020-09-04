import 'package:flutter/services.dart';

import './constants.dart';
import './superplayer_const.dart';
import './superplayer_model.dart';
import './superplayer_view.dart';

class SuperPlayerController {
  MethodChannel _channel;

  void initWithViewId(int viewId) {
    _channel = MethodChannel('${kSuperPlayerViewViewType}_$viewId');
  }

  void setPlayerViewCallback(OnSuperPlayerViewCallback callback) {
    // skip
  }

  void playWithModel(final SuperPlayerModel model) {
    _channel.invokeMethod('playWithModel', model.toJson());
  }

  void resetPlayer() {
    _channel.invokeMethod('resetPlayer');
  }

  void requestPlayMode(int playMode) {
    _channel.invokeMethod('requestPlayMode', {
      'playMode': playMode,
    });
  }

  Future<int> getPlayMode() async {
    return 0;
  }

  Future<int> getPlayState() async {
    return 0;
  }

  void release() {
    _channel.invokeMethod('release');
  }
}

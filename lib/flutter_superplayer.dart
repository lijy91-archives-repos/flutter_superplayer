import 'dart:async';

import 'package:flutter/services.dart';

export './src/superplayer_const.dart';
export './src/superplayer_controller.dart';
export './src/superplayer_model.dart';
export './src/superplayer_video_id.dart';
export './src/superplayer_video_id_v2.dart';
export './src/superplayer_view.dart';

class FlutterSuperPlayer {
  static const MethodChannel _channel =
      const MethodChannel('flutter_superplayer');

  static Future<String> get sdkVersion async {
    final String version = await _channel.invokeMethod('getSDKVersion');
    return version;
  }
}

import 'dart:async';

import 'package:flutter/services.dart';

export 'src/control_views/default/default.dart';
export 'src/constants.dart';
export 'src/superplayer_const.dart';
export 'src/superplayer_controller.dart';
export 'src/superplayer_listener.dart';
export 'src/superplayer_model.dart';
export 'src/superplayer_video_id.dart';
export 'src/superplayer_video_id_v2.dart';
export 'src/superplayer_view.dart';

class FlutterSuperPlayer {
  FlutterSuperPlayer._();

  /// The shared instance of [FlutterSuperPlayer].
  static final FlutterSuperPlayer instance = FlutterSuperPlayer._();

  final MethodChannel _channel = const MethodChannel('flutter_superplayer');

  Future<String> get sdkVersion async {
    final String version = await _channel.invokeMethod('getSDKVersion');
    return version;
  }
}

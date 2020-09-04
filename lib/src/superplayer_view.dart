import 'dart:io';

import 'package:flutter/material.dart';

import './constants.dart';
import './superplayer_controller.dart';

class SuperPlayerView extends StatelessWidget {
  final SuperPlayerController controller;

  const SuperPlayerView({
    Key key,
    this.controller,
  }) : super(key: key);

  void _onPlatformViewCreated(int viewId) {
    if (controller != null) controller.initWithViewId(viewId);
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: kSuperPlayerViewViewType,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: kSuperPlayerViewViewType,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Container();
  }
}

/// SuperPlayerView的回调接口
abstract class OnSuperPlayerViewCallback {
  /// 开始全屏播放
  void onStartFullScreenPlay();

  /// 结束全屏播放
  void onStopFullScreenPlay();

  /// 点击悬浮窗模式下的x按钮
  void onClickFloatCloseBtn();

  /// 点击小播放模式的返回按钮
  void onClickSmallReturnBtn();

  /// 开始悬浮窗播放
  void onStartFloatWindowPlay();
}

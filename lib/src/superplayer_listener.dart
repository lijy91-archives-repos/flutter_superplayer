abstract class SuperPlayerListener {
  /// 全屏切换
  void onFullScreenChange(bool isFullScreen);

  /// 点击悬浮窗模式下的x按钮
  void onClickFloatCloseBtn();

  /// 点击小播放模式的返回按钮
  void onClickSmallReturnBtn();

  /// 开始悬浮窗播放
  void onStartFloatWindowPlay();

  /// 播放状态发生变化
  void onPlayStateChange(int playState);

  /// 播放进度发生变化
  void onPlayProgressChange(int current, int duration);
}

/// 超级播放器常量
class SuperPlayerConst {
  // 播放模式
  static final int PLAYMODE_WINDOW = 1; // 窗口
  static final int PLAYMODE_FULLSCREEN = 2; // 全屏
  static final int PLAYMODE_FLOAT = 3; // 悬浮窗

  // 播放状态
  static final int PLAYSTATE_PLAYING = 1;
  static final int PLAYSTATE_PAUSE = 2;
  static final int PLAYSTATE_LOADING = 3;
  static final int PLAYSTATE_END = 4;

  // 屏幕方向
  static final int ORIENTATION_LANDSCAPE = 1; // 横屏
  static final int ORIENTATION_PORTRAIT = 2; // 竖屏

  // 播放视频类型
  static final int PLAYTYPE_VOD = 1; // 点播
  static final int PLAYTYPE_LIVE = 2; // 直播
  static final int PLAYTYPE_LIVE_SHIFT = 3; // 直播回看

  static final int MAX_SHIFT_TIME = 7200; // demo演示直播时移是MAX_SHIFT_TIMEs，即2小时
}

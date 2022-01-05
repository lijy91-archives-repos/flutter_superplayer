///< 图像铺满屏幕，不留黑边，如果图像宽高比不同于屏幕宽高比，部分画面内容会被裁剪掉。
const RENDER_MODE_FILL_SCREEN = 0;

///< 图像适应屏幕，保持画面完整，但如果图像宽高比不同于屏幕宽高比，会有黑边的存在。
const RENDER_MODE_FILL_EDGE = 1;

class SuperPlayerGlobleConfig {
  final int? renderMode;

  SuperPlayerGlobleConfig(this.renderMode);

  Map<String, dynamic> toJson() {
    return {
      'renderMode': renderMode,
    }..removeWhere((key, value) => value == null);
  }
}

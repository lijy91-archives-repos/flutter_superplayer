package com.tencent.liteav.demo.superplayer;

public class SuperPlayerDef {

    public enum PlayerMode {
        WINDOW,     // 窗口模式
        FULLSCREEN, // 全屏模式
        FLOAT       // 悬浮窗模式
    }

    public enum PlayerState {
        NONE(-1),       // 初始状态
        PLAYING(1),    // 播放中
        PAUSE(2),      // 暂停中
        LOADING(3),    // 缓冲中
        END(4);         // 结束播放

        final int value;
        PlayerState(int value) {
            this.value = value;
        }

        public int intValue() {
            return value;
        }
    }

    public enum PlayerType {
        VOD,        // 点播
        LIVE,       // 直播
        LIVE_SHIFT  // 直播会看
    }

    public enum Orientation {
        LANDSCAPE,  // 横屏
        PORTRAIT    // 竖屏
    }
}

package dev.learn_flutter.plugins.flutter_superplayer;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.tencent.liteav.demo.play.SuperPlayerConst;
import com.tencent.liteav.demo.play.SuperPlayerModel;
import com.tencent.liteav.demo.play.SuperPlayerVideoId;
import com.tencent.liteav.demo.play.SuperPlayerView;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;

import static dev.learn_flutter.plugins.flutter_superplayer.Constants.SUPER_PLAYER_VIEW_TYPE;

public class FlutterSuperPlayerView implements PlatformView, MethodCallHandler, SuperPlayerView.OnSuperPlayerViewCallback {
    private final MethodChannel methodChannel;
    private final Handler platformThreadHandler = new Handler(Looper.getMainLooper());

    private FrameLayout containerView;
    private SuperPlayerView superPlayerView;

    FlutterSuperPlayerView(
            final Context context,
            BinaryMessenger messenger,
            int viewId,
            Map<String, Object> params) {

        methodChannel = new MethodChannel(messenger, SUPER_PLAYER_VIEW_TYPE + "_" + viewId);
        methodChannel.setMethodCallHandler(this);

        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
                Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL
        );
        containerView = new FrameLayout(context);
        containerView.setLayoutParams(layoutParams);

        superPlayerView = new SuperPlayerView(context);
        superPlayerView.setPlayerViewCallback(this);
        containerView.addView(superPlayerView);
    }

    @Override
    public View getView() {
        return containerView;
    }

    @Override
    public void dispose() {
        if (superPlayerView.getPlayState() == SuperPlayerConst.PLAYSTATE_PLAYING) {
            superPlayerView.release();
        }
        this.containerView.removeAllViews();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("playWithModel")) {
            playWithModel(call, result);
        } else if (call.method.equals("resetPlayer")) {
            resetPlayer(call, result);
        } else if (call.method.equals("requestPlayMode")) {
            requestPlayMode(call, result);
        } else if (call.method.equals("getPlayMode")) {
            getPlayMode(call, result);
        } else if (call.method.equals("getPlayState")) {
            getPlayState(call, result);
        } else if (call.method.equals("release")) {
            release(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void playWithModel(@NonNull MethodCall call, @NonNull Result result) {
        SuperPlayerModel model = new SuperPlayerModel();

        if (call.hasArgument("appId"))
            model.appId = (int) call.argument("appId");


        if (call.hasArgument("videoId")) {
            HashMap<String, Object> videoIdJson = call.argument("videoId");
            assert videoIdJson != null;

            SuperPlayerVideoId videoId = new SuperPlayerVideoId();
            if (videoIdJson.containsKey("fileId"))
                videoId.fileId = (String) videoIdJson.get("fileId");

            model.videoId = videoId;
        }

        superPlayerView.playWithModel(model);
    }

    void resetPlayer(@NonNull MethodCall call, @NonNull Result result) {
        superPlayerView.resetPlayer();
    }

    void requestPlayMode(@NonNull MethodCall call, @NonNull Result result) {
        int playMode = (int) call.argument("playMode");
        superPlayerView.requestPlayMode(playMode);
    }

    void getPlayMode(@NonNull MethodCall call, @NonNull Result result) {
        int playMode = superPlayerView.getPlayState();
        result.success(playMode);
    }

    void getPlayState(@NonNull MethodCall call, @NonNull Result result) {
        int playState = superPlayerView.getPlayState();
        result.success(playState);
    }

    void release(@NonNull MethodCall call, @NonNull Result result) {
        superPlayerView.release();
    }

    @Override
    public void onStartFullScreenPlay() {

    }

    @Override
    public void onStopFullScreenPlay() {

    }

    @Override
    public void onClickFloatCloseBtn() {

    }

    @Override
    public void onClickSmallReturnBtn() {

    }

    @Override
    public void onStartFloatWindowPlay() {

    }
}

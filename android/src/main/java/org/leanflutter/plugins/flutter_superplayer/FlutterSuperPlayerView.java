package org.leanflutter.plugins.flutter_superplayer;

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
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;

import static org.leanflutter.plugins.flutter_superplayer.Constants.SUPER_PLAYER_VIEW_CHANNEL_NAME;
import static org.leanflutter.plugins.flutter_superplayer.Constants.SUPER_PLAYER_VIEW_EVENT_CHANNEL_NAME;

public class FlutterSuperPlayerView implements PlatformView, MethodCallHandler, StreamHandler, SuperPlayerView.OnSuperPlayerViewCallback {
    private final MethodChannel methodChannel;
    private final EventChannel eventChannel;
    private final Handler platformThreadHandler = new Handler(Looper.getMainLooper());

    private EventChannel.EventSink eventSink;

    private FrameLayout containerView;
    private SuperPlayerView superPlayerView;

    FlutterSuperPlayerView(
            final Context context,
            BinaryMessenger messenger,
            int viewId,
            Map<String, Object> params) {

        methodChannel = new MethodChannel(messenger, SUPER_PLAYER_VIEW_CHANNEL_NAME + "_" + viewId);
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(messenger, SUPER_PLAYER_VIEW_EVENT_CHANNEL_NAME + "_" + viewId);
        eventChannel.setStreamHandler(this);


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
    public void onListen(Object args, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object args) {
        this.eventSink = null;
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
        if (call.hasArgument("url"))
            model.url = (String) call.argument("url");

        if (call.hasArgument("videoId")) {
            HashMap<String, Object> videoIdJson = call.argument("videoId");
            assert videoIdJson != null;

            SuperPlayerVideoId videoId = new SuperPlayerVideoId();
            if (videoIdJson.containsKey("fileId"))
                videoId.fileId = (String) videoIdJson.get("fileId");
            if (videoIdJson.containsKey("pSign"))
                videoId.pSign = (String) videoIdJson.get("pSign");

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
        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onStartFullScreenPlay");

        eventSink.success(eventData);
    }

    @Override
    public void onStopFullScreenPlay() {
        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onStopFullScreenPlay");

        eventSink.success(eventData);
    }

    @Override
    public void onClickFloatCloseBtn() {
        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onClickFloatCloseBtn");

        eventSink.success(eventData);
    }

    @Override
    public void onClickSmallReturnBtn() {
        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onClickSmallReturnBtn");

        eventSink.success(eventData);

    }

    @Override
    public void onStartFloatWindowPlay() {
        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onStartFloatWindowPlay");

        eventSink.success(eventData);

    }
}

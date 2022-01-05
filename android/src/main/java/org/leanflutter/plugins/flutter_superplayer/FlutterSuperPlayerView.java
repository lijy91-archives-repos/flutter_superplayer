package org.leanflutter.plugins.flutter_superplayer;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.demo.superplayer.SuperPlayerDef;
import com.tencent.liteav.demo.superplayer.SuperPlayerGlobalConfig;
import com.tencent.liteav.demo.superplayer.SuperPlayerModel;
import com.tencent.liteav.demo.superplayer.SuperPlayerVideoId;
import com.tencent.liteav.demo.superplayer.SuperPlayerView;
import com.tencent.liteav.demo.superplayer.model.entity.VideoQuality;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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

    private Context context;
    private FrameLayout containerView;
    private SuperPlayerView superPlayerView;

    private long playProgressCurrent = 0;

    FlutterSuperPlayerView(
            final Context context,
            BinaryMessenger messenger,
            int viewId,
            Map<String, Object> params) {

        this.context = context;

        methodChannel = new MethodChannel(messenger, SUPER_PLAYER_VIEW_CHANNEL_NAME + "_" + viewId);
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(messenger, SUPER_PLAYER_VIEW_EVENT_CHANNEL_NAME + "_" + viewId);
        eventChannel.setStreamHandler(this);

        SuperPlayerGlobalConfig.getInstance().enableFloatWindow = false;

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

        TXCLog.setConsoleEnabled(true);
    }

    @Override
    public View getView() {
        return containerView;
    }

    @Override
    public void dispose() {
        if (superPlayerView.getPlayerState() == SuperPlayerDef.PlayerState.PLAYING) {
            superPlayerView.resetPlayer();
        }
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
        if (call.method.equals("getModel")) {
            getModel(call, result);
        } else if (call.method.equals("setRenderMode")) {
            setRenderMode(call, result);
        } else if (call.method.equals("getPlayMode")) {
            getPlayMode(call, result);
        } else if (call.method.equals("getPlayState")) {
            getPlayState(call, result);
        } else if (call.method.equals("getPlayRate")) {
            getPlayRate(call, result);
        } else if (call.method.equals("setPlayRate")) {
            setPlayRate(call, result);
        } else if (call.method.endsWith("getVideoQuality")) {
            getVideoQuality(call, result);
        } else if (call.method.endsWith("setVideoQuality")) {
            setVideoQuality(call, result);
        } else if (call.method.equals("resetPlayer")) {
            resetPlayer(call, result);
        } else if (call.method.equals("setStartTime")) {
            setStartTime(call, result);
        } else if (call.method.equals("playWithModel")) {
            playWithModel(call, result);
        } else if (call.method.equals("pause")) {
            pause(call, result);
        } else if (call.method.equals("resume")) {
            resume(call, result);
        } else if (call.method.equals("release")) {
            release(call, result);
        } else if (call.method.equals("seekTo")) {
            seekTo(call, result);
        } else if (call.method.equals("setLoop")) {
            setLoop(call, result);
        } else {
            result.notImplemented();
        }
    }

    void getModel(@NonNull MethodCall call, @NonNull Result result) {
        SuperPlayerModel model = superPlayerView.getPlayerModel();

        final List<Map<String, Object>> multiURLs = new ArrayList<>();
        if (model != null && model.multiURLs != null) {
            for (SuperPlayerModel.SuperPlayerURL superPlayerUrl : model.multiURLs) {
                final Map<String, Object> itemData = new HashMap<>();
                itemData.put("qualityName", superPlayerUrl.qualityName);
                itemData.put("url", superPlayerUrl.url);
                multiURLs.add(itemData);
            }
        }

        Map<String, List<Map<String, Object>>> resultData = new HashMap<>();
        resultData.put("multiURLs", multiURLs);

        result.success(resultData);
    }

    void setRenderMode(@NonNull MethodCall call, @NonNull Result result) {
        int renderMode = (int) call.argument("renderMode");
        superPlayerView.getSuperPlayer().setRenderMode(renderMode);
        result.success(true);
    }

    void getPlayMode(@NonNull MethodCall call, @NonNull Result result) {
        int playMode = superPlayerView.getPlayerMode().ordinal();
        result.success(playMode);
    }

    void getPlayState(@NonNull MethodCall call, @NonNull Result result) {
        SuperPlayerDef.PlayerState playerState = superPlayerView.getPlayerState();
        result.success(playerState.intValue());
    }

    void getPlayRate(@NonNull MethodCall call, @NonNull Result result) {
//        float playRate = superPlayerView.getPlayerRate();
//        result.success(playRate);
    }

    void setPlayRate(@NonNull MethodCall call, @NonNull Result result) {
        Number playRate = (Number) call.argument("playRate");
        superPlayerView.getControllerCallback().onSpeedChange(playRate.floatValue());
    }

    void getVideoQuality(@NonNull MethodCall call, @NonNull Result result) {
        SuperPlayerModel model = superPlayerView.getPlayerModel();

        try {
            String qualityName = "自动";
            String url = superPlayerView.getSuperPlayer().getPlayURL();
            try {
                SuperPlayerModel.SuperPlayerURL superPlayerURL = model.multiURLs.get(model.playDefaultIndex);
                qualityName = superPlayerURL.qualityName;
                url = superPlayerURL.url;
            } catch (Exception error) {}

            final Map<String, Object> resultData = new HashMap<>();
            resultData.put("qualityName", qualityName);
            resultData.put("url", url);

            result.success(resultData);
        } catch (Exception e) {
            e.printStackTrace();
            result.success(null);
        }
    }

    void setVideoQuality(@NonNull MethodCall call, @NonNull Result result) {
        String qualityName = (String) call.argument("qualityName");
        String url = (String) call.argument("url");

        VideoQuality videoQuality = new VideoQuality(0, qualityName, url);

        SuperPlayerModel model = superPlayerView.getPlayerModel();
        for (int i = 0; i < model.multiURLs.size(); i++) {
            SuperPlayerModel.SuperPlayerURL superPlayerURL = model.multiURLs.get(i);
            if (superPlayerURL.qualityName.equals(qualityName) && superPlayerURL.url.equals(url)) {
                videoQuality = new VideoQuality(i, superPlayerURL.qualityName, superPlayerURL.url);
                break;
            }
        }
        superPlayerView.getControllerCallback().onQualityChange(videoQuality);
    }

    private void resetPlayer(@NonNull MethodCall call, @NonNull Result result) {
        superPlayerView.resetPlayer();
    }

    private void setStartTime(@NonNull MethodCall call, @NonNull Result result) {
        int startTime = (int) call.argument("startTime");
        superPlayerView.setStartTime(startTime);
    }

    private void playWithModel(@NonNull MethodCall call, @NonNull Result result) {
        SuperPlayerModel model = new SuperPlayerModel();

        if (call.hasArgument("appId"))
            model.appId = (int) call.argument("appId");
        if (call.hasArgument("url"))
            model.url = (String) call.argument("url");
        if (call.hasArgument("coverPictureUrl"))
            model.coverPictureUrl = (String) call.argument("coverPictureUrl");

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

        if (call.hasArgument("multiURLs")) {
            List<HashMap<String, Object>> multiURLsJsonArray = call.argument("multiURLs");
            assert multiURLsJsonArray != null;

            List<SuperPlayerModel.SuperPlayerURL> multiURLs = new ArrayList<>();

            for (HashMap<String, Object> urlJsonObject : multiURLsJsonArray) {
                SuperPlayerModel.SuperPlayerURL superPlayerURL = new SuperPlayerModel.SuperPlayerURL();
                if (urlJsonObject.containsKey("url"))
                    superPlayerURL.url = (String) urlJsonObject.get("url");
                if (urlJsonObject.containsKey("qualityName"))
                    superPlayerURL.qualityName = (String) urlJsonObject.get("qualityName");
            }

            model.multiURLs = multiURLs;
        }

        superPlayerView.playWithModel(model);
    }

    void pause(@NonNull MethodCall call, @NonNull Result result) {
        superPlayerView.getControllerCallback().onPause();
    }

    void resume(@NonNull MethodCall call, @NonNull Result result) {
        superPlayerView.getControllerCallback().onResume();
    }

    void release(@NonNull MethodCall call, @NonNull Result result) {
        superPlayerView.release();
    }

    void seekTo(@NonNull MethodCall call, @NonNull Result result) {
        int time = (int) call.argument("time");
        superPlayerView.getControllerCallback().onSeekTo(time);
    }

    void setLoop(@NonNull MethodCall call, @NonNull Result result) {
        boolean isLoop = (boolean) call.argument("isLoop");
        superPlayerView.getSuperPlayer().setLoop(isLoop);
    }

    @Override
    public void onStartFullScreenPlay() {
        final Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("isFullScreen", true);

        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onFullScreenChange");
        eventData.put("data", dataMap);

        eventSink.success(eventData);
    }

    @Override
    public void onStopFullScreenPlay() {
        final Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("isFullScreen", false);

        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onFullScreenChange");
        eventData.put("data", dataMap);

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
    }

    @Override
    public void onPlaying() {

    }

    @Override
    public void onPlayEnd() {

    }

    @Override
    public void onError(int code) {

    }

    @Override
    public void onPlayStateChange(SuperPlayerDef.PlayerState playState) {
        final Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("playState", playState.intValue());

        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onPlayStateChange");
        eventData.put("data", dataMap);

        eventSink.success(eventData);
    }

    @Override
    public void onPlayProgressChange(long current, long duration) {
        boolean isProgressChange = playProgressCurrent == current;
        playProgressCurrent = current;

        if (isProgressChange) return;

        final Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("current", current);
        dataMap.put("duration", duration);

        final Map<String, Object> eventData = new HashMap<>();
        eventData.put("listener", "SuperPlayerListener");
        eventData.put("method", "onPlayProgressChange");
        eventData.put("data", dataMap);

        eventSink.success(eventData);
    }
}

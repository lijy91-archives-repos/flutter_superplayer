package dev.learn_flutter.plugins.flutter_superplayer;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public final class SuperPlayerViewFactory extends PlatformViewFactory {
    private final Activity activity;
    private final BinaryMessenger messenger;


    public SuperPlayerViewFactory(Activity activity, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);

        this.activity = activity;
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        return new FlutterSuperPlayerView(activity, messenger, viewId, params);
    }
}

package org.leanflutter.plugins.flutter_superplayer;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.platform.PlatformViewRegistry;

import static org.leanflutter.plugins.flutter_superplayer.Constants.CHANNEL_NAME;
import static org.leanflutter.plugins.flutter_superplayer.Constants.SUPER_PLAYER_VIEW_TYPE;

/**
 * FlutterSuperplayerPlugin
 */
public class FlutterSuperplayerPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
    private FlutterPluginBinding pluginBinding;
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);

        pluginBinding = flutterPluginBinding;
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(new FlutterSuperplayerPlugin());

        PlatformViewFactory superPlayerViewFactory = new SuperPlayerViewFactory(registrar.activity(), registrar.messenger());
        PlatformViewRegistry platformViewRegistry = registrar.platformViewRegistry();
        platformViewRegistry.registerViewFactory(SUPER_PLAYER_VIEW_TYPE, superPlayerViewFactory);

        registrar.addViewDestroyListener(view -> {
            // skip
            return false; // We are not interested in assuming ownership of the NativeView.
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);

        pluginBinding = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getSDKVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        PlatformViewFactory superPlayerViewFactory = new SuperPlayerViewFactory(binding.getActivity(), pluginBinding.getBinaryMessenger());
        PlatformViewRegistry platformViewRegistry = pluginBinding.getFlutterEngine().getPlatformViewsController().getRegistry();
        platformViewRegistry.registerViewFactory(SUPER_PLAYER_VIEW_TYPE, superPlayerViewFactory);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}

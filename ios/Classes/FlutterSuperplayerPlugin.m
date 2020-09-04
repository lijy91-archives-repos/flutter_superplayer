#import "FlutterSuperplayerPlugin.h"

@implementation FlutterSuperplayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_superplayer"
                                     binaryMessenger:[registrar messenger]];
    FlutterSuperplayerPlugin* instance = [[FlutterSuperplayerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];

    FLTSuperPlayerViewFactory* platformViewFactory = [[FLTSuperPlayerViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:platformViewFactory withId:@"plugins.learn_flutter.dev/superplayer_view"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getSDKVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end

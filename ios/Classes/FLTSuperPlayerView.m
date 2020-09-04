//
//  FLTSuperPlayerView.m
//
//  Created by Lijy91 on 2020/9/4.
//

#import "FLTSuperPlayerView.h"

// FLTSuperPlayerViewController
@implementation FLTSuperPlayerViewController {
    FLTSuperPlayerView* _superPlayerView;
    int64_t _viewId;
    FlutterMethodChannel* _channel;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if (self = [super init]) {
        _viewId = viewId;
        
        NSString* channelName = [NSString stringWithFormat:@"plugins.learn_flutter.dev/superplayer_view_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
          [weakSelf onMethodCall:call result:result];
        }];
        
        _superPlayerView = [[FLTSuperPlayerView alloc] initWithFrame:frame];
    }
    return self;
}

- (UIView*)view {
    return _superPlayerView;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([[call method] isEqualToString:@"playWithModel"]) {
        [self playWithModel:call result: result];
    } else if ([[call method] isEqualToString:@"resetPlayer"]) {
        [self resetPlayer:call result: result];
    } else if ([[call method] isEqualToString:@"getPlayMode"]) {
        [self getPlayMode:call result: result];
    } else if ([[call method] isEqualToString:@"getPlayState"]) {
        [self getPlayState:call result: result];
    } else if ([[call method] isEqualToString:@"release"]) {
        [self release:call result: result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)playWithModel:(FlutterMethodCall*)call
               result:(FlutterResult)result
{
    SuperPlayerModel *model = [[SuperPlayerModel alloc] init];
    
    NSNumber *appId = call.arguments[@"appId"];
    if (appId)
        [model setAppId: appId.longValue];
    
    NSDictionary *videoIdJson = call.arguments[@"videoId"];
    if (videoIdJson) {
        NSString *fileId = videoIdJson[@"fileId"];
        
        SuperPlayerVideoId *videoId = [[SuperPlayerVideoId alloc] init];
        if (fileId)
            [videoId setFileId:fileId];
        
        [model setVideoId:videoId];
    }

    [_superPlayerView playWithModel:model];
    
}

- (void)resetPlayer:(FlutterMethodCall*)call
             result:(FlutterResult)result
{
    [_superPlayerView resetPlayer];
}

- (void)getPlayMode:(FlutterMethodCall*)call
             result:(FlutterResult)result
{
    
}
- (void)getPlayState:(FlutterMethodCall*)call
              result:(FlutterResult)result
{
    
}

- (void)release:(FlutterMethodCall*)call
         result:(FlutterResult)result
{
    
}

@end

//
@implementation FLTSuperPlayerViewFactory{
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    FLTSuperPlayerViewController* superPlayerViewController = [[FLTSuperPlayerViewController alloc] initWithFrame:frame
                                                                                                   viewIdentifier:viewId
                                                                                                        arguments:args
                                                                                                  binaryMessenger:_messenger];
    return superPlayerViewController;
}
@end

@implementation FLTSuperPlayerView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
}

@end

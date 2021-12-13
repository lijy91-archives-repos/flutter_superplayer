//
//  FLTSuperPlayerView.m
//
//  Created by Lijy91 on 2020/9/4.
//
#import <SDWebImage/SDWebImage.h>
#import "FLTSuperPlayerView.h"

// FLTSuperPlayerViewController
@implementation FLTSuperPlayerViewController {
    UIView* _containerView;
    FLTSuperPlayerView* _superPlayerView;
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    FlutterEventChannel* _eventChannel;
    FlutterEventSink _eventSink;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if (self = [super init]) {
        _viewId = viewId;
        
        NSString* channelName = [NSString stringWithFormat:@"leanflutter.org/superplayer_view/channel_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        
        NSString* eventChannelName = [NSString stringWithFormat:@"leanflutter.org/superplayer_view/event_channel_%lld", viewId];
        _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName
                                                  binaryMessenger:messenger];
        [_eventChannel setStreamHandler:self];
        
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
        _containerView = [[UIView alloc] initWithFrame:frame];
        
        _superPlayerView = [[FLTSuperPlayerView alloc] init];
        _superPlayerView.fatherView = _containerView;
        _superPlayerView.delegate = self;
        
        if (args[@"coverImageUrl"] != nil) {
            [self setCoverImage:args[@"coverImageUrl"]];
        }
    }
    return self;
}

- (UIView*)view {
    return _containerView;
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    return nil;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([[call method] isEqualToString:@"getModel"]) {
        [self getModel:call result: result];
    } else if ([[call method] isEqualToString:@"setCoverImage"]) {
        [self setCoverImage:call result: result];
    } else if ([[call method] isEqualToString:@"getPlayMode"]) {
        [self getPlayMode:call result: result];
    } else if ([[call method] isEqualToString:@"getPlayState"]) {
        [self getPlayState:call result: result];
    } else if ([[call method] isEqualToString:@"getPlayRate"]) {
        [self getPlayRate:call result: result];
    } else if ([[call method] isEqualToString:@"setPlayRate"]) {
        [self setPlayRate:call result: result];
    } else if ([[call method] isEqualToString:@"getVideoQuality"]) {
        [self getVideoQuality:call result: result];
    } else if ([[call method] isEqualToString:@"setVideoQuality"]) {
        [self setVideoQuality:call result: result];
    } else if ([[call method] isEqualToString:@"resetPlayer"]) {
        [self resetPlayer:call result: result];
    } else if ([[call method] isEqualToString:@"setStartTime"]) {
        [self setStartTime:call result: result];
    } else if ([[call method] isEqualToString:@"playWithModel"]) {
        [self playWithModel:call result: result];
    } else if ([[call method] isEqualToString:@"pause"]) {
        [self pause:call result: result];
    } else if ([[call method] isEqualToString:@"resume"]) {
        [self resume:call result: result];
    } else if ([[call method] isEqualToString:@"release"]) {
        [self release:call result: result];
    } else if ([[call method] isEqualToString:@"seekTo"]) {
        [self seekTo:call result: result];
    } else if ([[call method] isEqualToString:@"setLoop"]) {
        [self setLoop:call result: result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)getModel:(FlutterMethodCall*)call
          result:(FlutterResult)result
{
    NSMutableArray *multiURLs = [[NSMutableArray alloc] init];
    for (SuperPlayerUrl *superPlayerUrl in _superPlayerView.playerModel.multiVideoURLs) {
        NSDictionary<NSString *, id> *itemData = @{
            @"qualityName": superPlayerUrl.title,
            @"url": superPlayerUrl.url == nil ?@"": superPlayerUrl.url,
        };
        [multiURLs addObject:itemData];
    }
    
    NSDictionary<NSString *, id> *resultData = @{
        @"multiURLs": multiURLs,
    };
    result(resultData);
}

- (void)setControlViewType:(NSString *)controlViewType
{
    if  ([controlViewType isEqualToString:@"without"]) {
        _superPlayerView.controlView = [[SPWithoutControlView alloc] initWithFrame:CGRectZero];
    } else {
        _superPlayerView.controlView = [[SPDefaultControlView alloc] initWithFrame:CGRectZero];
    }
}

- (void)setControlViewType:(FlutterMethodCall*)call
                    result:(FlutterResult)result
{
    NSString *controlViewType = call.arguments[@"controlViewType"];
    [self setControlViewType:controlViewType];
}

- (void)setTitle:(FlutterMethodCall*)call
          result:(FlutterResult)result
{
    NSString *title = call.arguments[@"title"];
    [_superPlayerView.controlView setTitle:title];
}

- (void)setCoverImage:(NSString *)coverImageUrl
{
    [_superPlayerView.coverImageView sd_setImageWithURL:[NSURL URLWithString:coverImageUrl]];
    _superPlayerView.coverImageView.alpha = 1;
}

- (void)setCoverImage:(FlutterMethodCall*)call
               result:(FlutterResult)result
{
    NSString *coverImageUrl = call.arguments[@"coverImageUrl"];
    [self setCoverImage:coverImageUrl];
}

- (void)getPlayMode:(FlutterMethodCall*)call
             result:(FlutterResult)result
{
    [_superPlayerView setPlayerConfig:nil];
}

- (void)getPlayState:(FlutterMethodCall*)call
              result:(FlutterResult)result
{
    result([NSNumber numberWithInt:_superPlayerView.state]);
}

- (void)getPlayRate:(FlutterMethodCall*)call
             result:(FlutterResult)result
{
    CGFloat playRate = [[_superPlayerView playerConfig] playRate];
    result([NSNumber numberWithDouble:playRate]);
}

- (void)setPlayRate:(FlutterMethodCall*)call
             result:(FlutterResult)result
{
    NSNumber *playRate = call.arguments[@"playRate"];
    [_superPlayerView setPlayRate:playRate.floatValue];
}


- (void)getVideoQuality:(FlutterMethodCall*)call
                 result:(FlutterResult)result
{
    SuperPlayerUrl *superPlayerUrl;
    
    superPlayerUrl = [_superPlayerView getVideoQuality];
    
    if (superPlayerUrl != nil) {
        NSDictionary<NSString *, id> *resultData = @{
            @"qualityName": superPlayerUrl.title,
            @"url": superPlayerUrl.url == nil ?@"": superPlayerUrl.url,
        };
        result(resultData);
    } else {
        result(nil);
    }
}

- (void)setVideoQuality:(FlutterMethodCall*)call
                 result:(FlutterResult)result
{
    NSString *qualityName = call.arguments[@"qualityName"];
    NSString *url = call.arguments[@"url"];
    
    SuperPlayerUrl *superPlayerUrl = [[SuperPlayerUrl alloc] init];
    superPlayerUrl.title = qualityName;
    superPlayerUrl.url = url;
    
    [_superPlayerView setVideoQuality:superPlayerUrl];
}

- (void)resetPlayer:(FlutterMethodCall*)call
             result:(FlutterResult)result
{
    [_superPlayerView resetPlayer];
}


- (void)setStartTime:(FlutterMethodCall*)call
              result:(FlutterResult)result
{
    NSNumber *startTime = call.arguments[@"startTime"];
    if (startTime.intValue > 0) {
        [_superPlayerView setStartTime:startTime.intValue];
    }
}

- (void)playWithModel:(FlutterMethodCall*)call
               result:(FlutterResult)result
{
    SuperPlayerModel *model = [[SuperPlayerModel alloc] init];
    
    NSNumber *appId = call.arguments[@"appId"];
    NSString *url = call.arguments[@"url"];
    if (appId)
        [model setAppId: appId.longValue];
    if (url)
        [model setVideoURL:url];
    
    NSDictionary *videoIdJson = call.arguments[@"videoId"];
    if (videoIdJson) {
        NSString *fileId = videoIdJson[@"fileId"];
        NSString *pSign = videoIdJson[@"pSign"];
        
        SuperPlayerVideoId *videoId = [[SuperPlayerVideoId alloc] init];
        if (fileId)
            [videoId setFileId:fileId];
        if (pSign)
            [videoId setPsign:pSign];
        
        [model setVideoId:videoId];
    }
    
    [_superPlayerView playWithModel:model];
}

- (void)pause:(FlutterMethodCall*)call
       result:(FlutterResult)result
{
    [_superPlayerView pause];
}

- (void)resume:(FlutterMethodCall*)call
        result:(FlutterResult)result
{
    [_superPlayerView resume];
}

- (void)release:(FlutterMethodCall*)call
         result:(FlutterResult)result
{
    _superPlayerView = nil;
}

- (void)seekTo:(FlutterMethodCall*)call
        result:(FlutterResult)result
{
    NSNumber *time = call.arguments[@"time"];
    [_superPlayerView seekToTime:time.intValue];
}

- (void)setLoop:(FlutterMethodCall*)call
         result:(FlutterResult)result
{
    NSNumber *isLoop = call.arguments[@"isLoop"];
    [_superPlayerView setLoop:isLoop.boolValue];
}

/// 返回事件
- (void)superPlayerBackAction:(SuperPlayerView *)player {
    NSDictionary<NSString *, id> *eventData = @{
        @"listener": @"SuperPlayerListener",
        @"method": @"onClickSmallReturnBtn",
    };
    self->_eventSink(eventData);
}

/// 全屏改变通知
- (void)superPlayerFullScreenChanged:(SuperPlayerView *)player {
    //    NSDictionary<NSString *, id> *eventData = @{
    //        @"listener": @"SuperPlayerListener",
    //        @"method": @"onFullScreenChange",
    //        @"data": @{
    //                @"isFullScreen": [NSNumber numberWithBool:[player isFullScreen]],
    //        },
    //    };
    //    self->_eventSink(eventData);
}

/// 播放开始通知
- (void)superPlayerDidStart:(SuperPlayerView *)player {
    
}
/// 播放结束通知
- (void)superPlayerDidEnd:(SuperPlayerView *)player {
    
}
/// 播放错误通知
- (void)superPlayerError:(SuperPlayerView *)player errCode:(int)code errMessage:(NSString *)why {
    
}

/// 播放状态发生变化
- (void)onPlayStateChange:(int) playState {
    NSDictionary<NSString *, id> *eventData = @{
        @"listener": @"SuperPlayerListener",
        @"method": @"onPlayStateChange",
        @"data": @{
            @"playState": [NSNumber numberWithInt:playState],
        },
    };
    self->_eventSink(eventData);
}

/// 播放进度发生变化
- (void)onPlayProgressChange:(int) current duration:(int) duration {
    NSDictionary<NSString *, id> *eventData = @{
        @"listener": @"SuperPlayerListener",
        @"method": @"onPlayProgressChange",
        @"data": @{
            @"current": [NSNumber numberWithInt:current],
            @"duration": [NSNumber numberWithInt:duration],
        },
    };
    self->_eventSink(eventData);
}

@end

// FLTSuperPlayerViewFactory
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

// FLTSuperPlayerView
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

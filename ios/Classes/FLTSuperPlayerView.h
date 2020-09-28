//
//  SuperPlayerView.h
//
//  Created by Lijy91 on 2020/9/4.
//

#import <Flutter/Flutter.h>
#import "SuperPlayer.h"

NS_ASSUME_NONNULL_BEGIN

// FLTSuperPlayerViewController
@interface FLTSuperPlayerViewController : NSObject <FlutterPlatformView, FlutterStreamHandler, SuperPlayerDelegate>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (UIView*)view;

@end

// FLTSuperPlayerViewFactory
@interface FLTSuperPlayerViewFactory : NSObject
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

// FLTSuperPlayerView
@interface FLTSuperPlayerView : SuperPlayerView
@end

NS_ASSUME_NONNULL_END

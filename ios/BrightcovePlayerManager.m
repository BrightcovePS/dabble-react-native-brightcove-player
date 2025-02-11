#import "BrightcovePlayerManager.h"
#import "BrightcovePlayer.h"
#import <React/RCTUIManager.h>

@implementation BrightcovePlayerManager

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

- (UIView *)view {
  return [[BrightcovePlayer alloc] init];
}

- (dispatch_queue_t)methodQueue {
  return _bridge.uiManager.methodQueue;
}

RCT_EXPORT_VIEW_PROPERTY(policyKey, NSString);
RCT_EXPORT_VIEW_PROPERTY(accountId, NSString);
RCT_EXPORT_VIEW_PROPERTY(videoId, NSString);
RCT_EXPORT_VIEW_PROPERTY(referenceId, NSString);
RCT_EXPORT_VIEW_PROPERTY(videoToken, NSString);
RCT_EXPORT_VIEW_PROPERTY(playlistReferenceId, NSString);
RCT_EXPORT_VIEW_PROPERTY(playlistId, NSString);
RCT_EXPORT_VIEW_PROPERTY(autoPlay, BOOL);
RCT_EXPORT_VIEW_PROPERTY(play, BOOL);
RCT_EXPORT_VIEW_PROPERTY(fullscreen, BOOL);
RCT_EXPORT_VIEW_PROPERTY(disableDefaultControl, BOOL);
RCT_EXPORT_VIEW_PROPERTY(volume, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(bitRate, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(playbackRate, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(seekDuration, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(onReady, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlay, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPause, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCloseTapped, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onEnd, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onProgress, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onChangeDuration, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onUpdateBufferProgress, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onEnterFullscreen, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onExitFullscreen, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayNextVideo, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoSize, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock);


RCT_EXPORT_METHOD(seekTo:(nonnull NSNumber *)reactTag seconds:(nonnull NSNumber *)seconds) {
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    BrightcovePlayer *player = (BrightcovePlayer*)viewRegistry[reactTag];
    if ([player isKindOfClass:[BrightcovePlayer class]]) {
      [player seekTo:seconds];
    }
  }];
}

RCT_EXPORT_METHOD(dispose:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    BrightcovePlayer *player = (BrightcovePlayer*)viewRegistry[reactTag];
    if ([player isKindOfClass:[BrightcovePlayer class]]) {
      [player dispose];
    }
  }];
}
RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    BrightcovePlayer *player = (BrightcovePlayer*)viewRegistry[reactTag];
    if ([player isKindOfClass:[BrightcovePlayer class]]) {
      [player.playbackController play];
    }
  }];
}
RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    BrightcovePlayer *player = (BrightcovePlayer*)viewRegistry[reactTag];
    if ([player isKindOfClass:[BrightcovePlayer class]]) {
      [player.playbackController pause];
    }
  }];
}
@end

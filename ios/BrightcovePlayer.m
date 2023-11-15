#import "BrightcovePlayer.h"
#import "BrightcovePlayerOfflineVideoManager.h"
#import "react_native_brightcove_player-Swift.h"
@interface BrightcovePlayer () <BCOVPlaybackControllerDelegate, BCOVPUIPlayerViewDelegate, RCTPlayerProtocol>
@end

@implementation BrightcovePlayer

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setup];
  }
  return self;
}

- (void)setup {
  _playbackController = [BCOVPlayerSDKManager.sharedManager createPlaybackController];
  [self createNewPlaybackController];
  _playbackController.delegate = self;
  _playbackController.autoPlay = _autoPlay;
  _playbackController.autoAdvance = YES;
  _playbackController.allowsExternalPlayback = YES;
  _playbackController.allowsBackgroundAudioPlayback = YES;
  
  _playerView = [[PlayerView alloc] initWithPresentingView: [self parentViewController] playbackController:_playbackController player: self];
  _playerView.delegate = self;
  _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  _playerView.backgroundColor = UIColor.blackColor;
  
  _targetVolume = 1.0;
  [self setUpAudioSession];
  //_autoPlay = NO;
  
  [self addSubview:_playerView];
}

- (void)setUpAudioSession
{
    NSError *categoryError = nil;

    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:&categoryError];
    
    if (!success)
    {
        NSLog(@"AppDelegate Debug - Error setting AVAudioSession category.  Because of this, there may be no sound. `%@`", categoryError);
    }
}

- (void)createNewPlaybackController {
  // The playback controller with
  // videos, or "clear" videos (no DRM protection).
  BCOVPlayerSDKManager *sdkManager = [BCOVPlayerSDKManager sharedManager];

  // Publisher/application IDs not required for Dynamic Delivery
  self.authProxy = [[BCOVFPSBrightcoveAuthProxy alloc] initWithPublisherId:nil
                                                             applicationId:nil];

  // You can use the same auth proxy for the offline video manager
  // and the call to create the FairPlay session provider.
  BCOVOfflineVideoManager.sharedManager.authProxy = self.authProxy;

  // Create the session provider chain
  BCOVBasicSessionProviderOptions *options = [[BCOVBasicSessionProviderOptions alloc] init];
  options.sourceSelectionPolicy = [BCOVBasicSourceSelectionPolicy sourceSelectionHLSWithScheme:kBCOVSourceURLSchemeHTTPS];
  id<BCOVPlaybackSessionProvider> basicSessionProvider = [sdkManager createBasicSessionProviderWithOptions:options];
  id<BCOVPlaybackSessionProvider> fairPlaySessionProvider = [sdkManager createFairPlaySessionProviderWithApplicationCertificate:nil
                                                                                                             authorizationProxy:self.authProxy
                                                                                                        upstreamSessionProvider:basicSessionProvider];

  // Create the playback controller
    
    
    id<BCOVPlaybackController> playbackController = [sdkManager createPlaybackControllerWithSessionProvider:fairPlaySessionProvider
                                                                                                  viewStrategy:nil];

  // Start playing right away (the default value for autoAdvance is NO)
  playbackController.autoAdvance = YES;
  playbackController.autoPlay = _autoPlay;

  // Register for delegate method callbacks
  playbackController.delegate = self;

  // Retain the playback controller
  self.playbackController = playbackController;
}


- (void)setupService {
  if ((!_playbackService || _playbackServiceDirty) && _accountId && _policyKey) {
    _playbackServiceDirty = NO;
    _playbackService = [[BCOVPlaybackService alloc] initWithAccountId:_accountId policyKey:nil];
  }
}

- (void)loadMovie {
  if (_videoToken) {
    BCOVVideo *video = [[BrightcovePlayerOfflineVideoManager sharedManager] videoObjectFromOfflineVideoToken:_videoToken];
    if (video) {
      [self.playbackController setVideos: @[ video ]];
    }
    return;
  }
  if (!_playbackService) return;
  if (_videoId) {
    if ([self.videoId isEqual: self.playerView.videoId]) {
      return;
    }
      NSDictionary *configuration = @{kBCOVPlaybackServiceConfigurationKeyAssetID:_videoId};
      [_playbackService findVideoWithConfiguration:configuration queryParameters:nil completion:^(BCOVVideo *video, NSDictionary *jsonResponse, NSError *error) {
          if (error) {
            if (self.onError) {
              self.onError(@{
                @"error":  error.userInfo
              });
            }
          }
          if (video) {
            [self setupVideoProperties: video];
            [self.playbackController setVideos: @[ video ]];
          }
        }];
  } else if (_referenceId) {
    if ([self.referenceId isEqual: self.playerView.referenceId]) {
      return;
    }
      NSDictionary *configuration = @{kBCOVPlaybackServiceConfigurationKeyAssetReferenceID:_referenceId};
      [_playbackService findVideoWithConfiguration:configuration queryParameters:nil completion:^(BCOVVideo *video, NSDictionary *jsonResponse, NSError *error) {
          if (error) {
            if (self.onError) {
              self.onError(@{
                @"error":  error.userInfo
              });
            }
          }
          if (video) {
            [self setupVideoProperties: video];
            [self.playbackController setVideos: @[ video ]];
          }
        }];
  }
}
-(void) setupVideoProperties: (BCOVVideo*) video {
  self.playerView.referenceId = video.properties[kBCOVVideoPropertyKeyReferenceId];
  self.playerView.videoId = video.properties[kBCOVVideoPropertyKeyId];
}

- (id<BCOVPlaybackController>)createPlaybackController {
  BCOVBasicSessionProviderOptions *options = [BCOVBasicSessionProviderOptions alloc];
  BCOVBasicSessionProvider *provider = [[BCOVPlayerSDKManager sharedManager] createBasicSessionProviderWithOptions:options];
  return [BCOVPlayerSDKManager.sharedManager createPlaybackControllerWithSessionProvider:provider viewStrategy:nil];
}

- (void)setReferenceId:(NSString *)referenceId {
  _referenceId = referenceId;
  _videoId = NULL;
  [self setupService];
  [self loadMovie];
}

- (void)setVideoId:(NSString *)videoId {
  _videoId = videoId;
  _referenceId = NULL;
  _videoToken = NULL;
  [self setupService];
  [self loadMovie];
}

- (void)setVideoToken:(NSString *)videoToken {
  _videoToken = videoToken;
  [self loadMovie];
}

- (void)setAccountId:(NSString *)accountId {
  _accountId = accountId;
  _playerView.accountId = _accountId;
  _playbackServiceDirty = YES;
  [self setupService];
  [self loadMovie];
}

- (void)setPolicyKey:(NSString *)policyKey {
  _policyKey = policyKey;
  _playerView.policyKey = _policyKey;
  _playbackServiceDirty = YES;
  [self setupService];
  [self loadMovie];
}
- (void)setPlaylistReferenceId:(NSString *)playlistReferenceId {
  _playlistReferenceId = playlistReferenceId;
  _playerView.playlistReferenceId = _playlistReferenceId;
}
- (void)setPlaylistId:(NSString *)playlistId {
  _playerView.playlistId = playlistId;
}
- (void)setAutoPlay:(BOOL)autoPlay {
  _autoPlay = autoPlay;
  _playbackController.autoPlay = _autoPlay;
}

- (void)setPlay:(BOOL)play {
  if (_playing == play) return;
  if (play) {
    [_playbackController play];
  } else {
    [_playbackController pause];
  }
}

- (void)setFullscreen:(BOOL)fullscreen {
  if (fullscreen) {
    [_playerView performScreenTransitionWithScreenMode:BCOVPUIScreenModeFull];
  } else {
    [_playerView performScreenTransitionWithScreenMode:BCOVPUIScreenModeNormal];
  }
}

- (void)setVolume:(NSNumber*)volume {
  _targetVolume = volume.doubleValue;
  [self refreshVolume];
}

- (void)setBitRate:(NSNumber*)bitRate {
  _targetBitRate = bitRate.doubleValue;
  [self refreshBitRate];
}

- (void)setPlaybackRate:(NSNumber*)playbackRate {
  _targetPlaybackRate = playbackRate.doubleValue;
  if (_playing) {
    [self refreshPlaybackRate];
  }
}

- (void)setSeekDuration:(NSNumber*)seekDuration {
  _playerView.seekDuration = seekDuration.doubleValue;
}

- (void)refreshVolume {
  if (!_playbackSession) return;
  _playbackSession.player.volume = _targetVolume;
}

- (void)refreshBitRate {
  if (!_playbackSession) return;
  AVPlayerItem *item = _playbackSession.player.currentItem;
  if (!item) return;
  item.preferredPeakBitRate = _targetBitRate;
}

- (void)refreshPlaybackRate {
  if (!_playbackSession || !_targetPlaybackRate) return;
  _playbackSession.player.rate = _targetPlaybackRate;
}

- (void)setDisableDefaultControl:(BOOL)disable {
  _playerView.controlsView.hidden = disable;
}

- (void)seekTo:(NSNumber *)time {
  [_playbackController seekToTime:CMTimeMakeWithSeconds([time floatValue], NSEC_PER_SEC) completionHandler:^(BOOL finished) {
  }];
}

- (void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didReceiveLifecycleEvent:(BCOVPlaybackSessionLifecycleEvent *)lifecycleEvent {
    
  if ((lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventFail) ||
      (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventFailedToPlayToEndTime) ||
      (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventResumeFail) ||
      (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventError || lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventPlaybackStalled)) {
    NSError *error = lifecycleEvent.properties[kBCOVPlaybackSessionEventKeyError];
    if (self.onError) {
      self.onError(@{
          @"error": lifecycleEvent.eventType ?: @"PlaybackBufferEmpty"
      });
    }
  }

  if (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventPlaybackBufferEmpty || lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventFail ||
      lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventError ||
      lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventTerminate) {
    _playbackSession = nil;
    return;
  }
  _playbackSession = session;
  if (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventReady) {
    [self refreshVolume];
    [self refreshBitRate];
    [_playerView checkVideoSize];
    if (self.onReady) {
      self.onReady(@{});
    }
//    if (_autoPlay) {
//        [_playbackController play];
//    } else {
//        [_playbackController pause];
//    }
  } else if (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventPlay) {
    _playing = true;
    [self refreshPlaybackRate];
    if (self.onPlay) {
      self.onPlay(@{});
    }
  } else if (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventPause) {
    _playing = false;
    if (self.onPause) {
      self.onPause(@{});
    }
  } else if (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventEnd) {
    _playerView.controlsView.routeDetector.routeDetectionEnabled = NO;
    if (self.onEnd) {
      self.onEnd(@{});
    }
  }
}

- (void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didChangeDuration:(NSTimeInterval)duration {
  if (self.onChangeDuration) {
    self.onChangeDuration(@{
      @"duration": @(duration)
                          });
  }
}
- (void)playbackController:(id<BCOVPlaybackController>)controller didAdvanceToPlaybackSession:(id<BCOVPlaybackSession>)session
{
  // Enable route detection for AirPlay
  // https://developer.apple.com/documentation/avfoundation/avroutedetector/2915762-routedetectionenabled
  _playerView.controlsView.routeDetector.routeDetectionEnabled = YES;
}
-(void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didProgressTo:(NSTimeInterval)progress {
  if (self.onProgress && progress > 0 && progress != INFINITY) {
    self.onProgress(@{
      @"currentTime": @(progress)
                    });
  }
  float bufferProgress = _playerView.controlsView.progressSlider.bufferProgress;
  if (_lastBufferProgress != bufferProgress) {
    _lastBufferProgress = bufferProgress;
    self.onUpdateBufferProgress(@{
      @"bufferProgress": @(bufferProgress),
                                });
  }
}

-(void)playerView:(BCOVPUIPlayerView *)playerView didTransitionToScreenMode:(BCOVPUIScreenMode)screenMode {
  if (screenMode == BCOVPUIScreenModeNormal) {
    _playerView.screenMode = @"BCOVPUIScreenModeNormal";
    if (self.onExitFullscreen) {
      self.onExitFullscreen(@{});
    }
  } else if (screenMode == BCOVPUIScreenModeFull) {
    _playerView.screenMode = @"BCOVPUIScreenModeFull";
    if (self.onEnterFullscreen) {
      self.onEnterFullscreen(@{});
    }
  }
}

-(void)dispose { //RBR -104
    [_playerView clearSubscriber];
    [self.playbackController pause];
    [self.playbackController setVideos:@[]];
    _playbackController = nil;
}

- (UIViewController *)parentViewController {
  UIResponder *parentResponder = self;
  while (parentResponder != nil) {
    parentResponder = [parentResponder nextResponder];
    if ([parentResponder isKindOfClass:[UIViewController class]]) {
      return (UIViewController *)parentResponder;
    }
  }
  return nil;
}
- (void)progressSliderDidChangeValue:(UISlider *)slider {
  _playerView.sliderDidChangeValue = [NSNumber numberWithFloat: slider.value];
}
- (void)progressSliderDidTouchUp:(UISlider *)slider {
  _playerView.slider = slider;
}
-(void)closeTapped {
    if (self.onCloseTapped) {
        [_playbackController pause];
      self.onCloseTapped(@{});
    }
}
- (void)nextVideoPlayer:(NSDictionary *)video {
  _referenceId =  [video valueForKey:@"referenceId"];
  _videoId =  [video valueForKey:@"videoId"];
  NSMutableDictionary *nextVideo = [NSMutableDictionary dictionary];
  [nextVideo setObject: _referenceId  forKey: @"referenceId"];
  [nextVideo setObject: _videoId  forKey: @"videoId"];
  if (self.onPlayNextVideo) {
    self.onPlayNextVideo(nextVideo);
//      [self setPlay:YES];
      
  }
}

-(void)videoSize:(double)width height:(double) height {
  NSMutableDictionary *videoSize = [NSMutableDictionary dictionary];
  [videoSize setObject: [NSNumber numberWithFloat: width]  forKey: @"width"];
  [videoSize setObject: [NSNumber numberWithFloat: height]  forKey: @"height"];
  if (self.onVideoSize) {
  self.onVideoSize(videoSize);
  }
}

-(void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
  NSLog(@"PIP will start");
}
-(void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
  NSLog(@"PIP Did start");
}
-(void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
  NSLog(@"PIP will stop");
}
-(void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
  NSLog(@"PIP did stop");
}
@end

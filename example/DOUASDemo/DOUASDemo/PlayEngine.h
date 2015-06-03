//
//  PlayEngine.h
//  DOUASDemo
//
//  Created by WangYunzhen on 15/6/3.
//  Copyright (c) 2015年 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioStreamer.h"

@class Track;

@protocol PlayEngineDelegate <NSObject>

@optional
- (void)onDurationChange:(NSTimeInterval)duration
          andCurrentTime:(NSTimeInterval)currentTime;
- (void)onStatusChange:(DOUAudioStreamerStatus)status;
- (void)onBufferingRatioReceivedLength:(NSUInteger)receivedLength
                expectedLength:(NSUInteger)expectedLength
                bufferingRatio:(double)bufferingRatio
                 downloadSpeed:(NSUInteger)downloadSpeed;
- (void)onTrackChange:(Track *)currentTrack;

@end

@interface PlayEngine : NSObject

@property (nonatomic, strong) DOUAudioStreamer *streamer;
@property (nonatomic, weak) id<PlayEngineDelegate> delegate;

+ (instancetype)sharedInstance;
+ (void)setVolume:(float)volume;

- (void)actionPlayNextSong;
- (void)actionPlayLastSong;
- (void)actionPlayPause;
- (void)actionStop;
- (void)actionSetCurrentDuration:(float)value;

- (DOUAudioStreamerStatus)status;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;
- (Track *)currentTrack;
- (double)volume;

@end

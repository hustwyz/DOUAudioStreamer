//
//  PlayEngine.m
//  DOUASDemo
//
//  Created by WangYunzhen on 15/6/3.
//  Copyright (c) 2015年 Douban Inc. All rights reserved.
//

#import "PlayEngine.h"
#import "DOUAudioStreamer.h"
#import "Track.h"
#import "TrackStore.h"
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface PlayEngine()

@end

@implementation PlayEngine

+ (instancetype)sharedInstance
{
    static PlayEngine *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PlayEngine alloc] init];
    });
    return instance;
}

+ (void)setVolume:(float)volume
{
    [DOUAudioStreamer setVolume:volume];
}

#pragma mark - play action
- (void)actionPlayNextSong
{
    [self playTrack:[[TrackStore sharedInstance] nextTrack]];
}

- (void)actionPlayLastSong
{
    
}

- (void)actionPlayPause
{
    if (_streamer) {
        if ([_streamer status] == DOUAudioStreamerPaused ||
            [_streamer status] == DOUAudioStreamerIdle) {
            [_streamer play];
        } else {
            [_streamer pause];
        }
    } else {
        [self playTrack:[[TrackStore sharedInstance] currentTrack]];
    }
}

- (void)actionStop
{
    [self cancelStreamer];
}

- (void)actionSetCurrentDuration:(float)value
{
    [_streamer setCurrentTime:[_streamer duration] * value];
}

#pragma mark - getter wrapper
- (DOUAudioStreamerStatus)status
{
    return _streamer ? _streamer.status : DOUAudioStreamerIdle;
}

- (NSTimeInterval)currentTime
{
    return _streamer ? _streamer.currentTime : 0;
}

- (NSTimeInterval)duration
{
    return _streamer ? _streamer.duration : 0;
}

- (Track *)currentTrack
{
    return [[TrackStore sharedInstance]currentTrack];
}

- (double)volume
{
    return [DOUAudioStreamer volume];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        NSLog(@"kStatusKVOKey");
        [self performSelector:@selector(onUpdateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else if (context == kDurationKVOKey) {
        NSLog(@"kDurationKVOKey");
        [self performSelector:@selector(onUpdateDuration)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else if (context == kBufferingRatioKVOKey) {
        NSLog(@"kBufferingRatioKVOKey");
        [self performSelector:@selector(onUpdateBufferRatio)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - private action
- (void)cancelStreamer
{
    if (_streamer != nil) {
        [_streamer stop];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        _streamer = nil;
        
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    }
}

- (void)playTrack:(Track *)track
{
    [self cancelStreamer];
    
    if ([self.delegate respondsToSelector:@selector(onTrackChange:)]) {
        [self.delegate onTrackChange:track];
    }
    
    if (track) {
        _streamer = [DOUAudioStreamer streamerWithAudioFile:track];
        [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
        [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
        
        [_streamer play];
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        [self creatBackPlay:track];
    } else {
        NSLog(@"no track");
    }
}

- (void)onUpdateStatus
{
    if ([self.delegate respondsToSelector:@selector(onStatusChange:)]) {
        [self.delegate onStatusChange:_streamer.status];
    }
}

- (void)onUpdateDuration
{
    if ([self.delegate respondsToSelector:@selector(onDurationChange:andCurrentTime:)]) {
        [self.delegate onDurationChange:_streamer.duration
                         andCurrentTime:_streamer.currentTime];
    }
}

- (void)onUpdateBufferRatio
{
    if ([self.delegate respondsToSelector:@selector(onBufferingRatioReceivedLength:expectedLength:bufferingRatio:downloadSpeed:)]){
        [self.delegate onBufferingRatioReceivedLength:_streamer.receivedLength
                                       expectedLength:_streamer.expectedLength
                                       bufferingRatio:_streamer.bufferingRatio
                                        downloadSpeed:_streamer.downloadSpeed];
    }
}

-(void)creatBackPlay:(Track *)track
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];
        
        UIImage *image = [UIImage imageNamed:@"cover_large.jpg"];
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
        [ songInfo setObject: track.title  forKey:MPMediaItemPropertyTitle];
        [ songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
        [ songInfo setObject: track.artist forKey:MPMediaItemPropertyArtist];
        [ [MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

-(void)dealloc
{
    NSLog(@"dealloc");
    [self cancelStreamer];
}

@end

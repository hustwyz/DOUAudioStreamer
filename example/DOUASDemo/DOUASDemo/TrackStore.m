//
//  TrackStore.m
//  DOUASDemo
//
//  Created by WangYunzhen on 15/6/3.
//  Copyright (c) 2015年 Douban Inc. All rights reserved.
//

#import "TrackStore.h"

@implementation TrackStore

+ (instancetype)sharedInstance
{
    static TrackStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TrackStore alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _currentTrackIndex = 0;
    }
    return self;
}

- (Track *)nextTrack
{
    if (self.tracks.count <= 0) {
        return nil;
    }
    if (++_currentTrackIndex >= [_tracks count]) {
        _currentTrackIndex = 0;
    }
    return [_tracks objectAtIndex:_currentTrackIndex];
}

- (Track *)currentTrack
{
    if (self.tracks.count <= 0) {
        return nil;
    }
    return [_tracks objectAtIndex:_currentTrackIndex];
}

@end

//
//  TrackStore.h
//  DOUASDemo
//
//  Created by WangYunzhen on 15/6/3.
//  Copyright (c) 2015年 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;

@interface TrackStore : NSObject

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, assign) NSUInteger currentTrackIndex;

+ (instancetype)sharedInstance;

- (Track *)nextTrack;
- (Track *)currentTrack;

@end

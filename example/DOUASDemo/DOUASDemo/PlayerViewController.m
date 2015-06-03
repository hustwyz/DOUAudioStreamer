//
//  PlayerControllerViewController.m
//  DOUASDemo
//
//  Created by WangYunzhen on 15/6/3.
//  Copyright (c) 2015年 Douban Inc. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayEngine.h"
#import "DOUAudioVisualizer.h"
#import "Track.h"

@interface PlayerViewController () <PlayEngineDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *miscLabel;

@property (nonatomic, strong) UIButton *buttonPlayPause;
@property (nonatomic, strong) UIButton *buttonNext;
@property (nonatomic, strong) UIButton *buttonStop;

@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) DOUAudioVisualizer *audioVisualizer;

@end

@implementation PlayerViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 64.0, CGRectGetWidth([view bounds]), 30.0)];
    [_titleLabel setFont:[UIFont systemFontOfSize:20.0]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_titleLabel];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_titleLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 30.0)];
    [_statusLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_statusLabel setTextColor:[UIColor colorWithWhite:0.4 alpha:1.0]];
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_statusLabel];
    
    _miscLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_statusLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 20.0)];
    [_miscLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_miscLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
    [_miscLabel setTextAlignment:NSTextAlignmentCenter];
    [_miscLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_miscLabel];
    
    _buttonPlayPause = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPlayPause setFrame:CGRectMake(80.0, CGRectGetMaxY([_miscLabel frame]) + 20.0, 60.0, 20.0)];
    [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    [_buttonPlayPause addTarget:self action:@selector(_actionPlayPause:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPlayPause];
    
    _buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonNext setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 80.0 - 60.0, CGRectGetMinY([_buttonPlayPause frame]), 60.0, 20.0)];
    [_buttonNext setTitle:@"Next" forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(_actionNext:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonNext];
    
    _buttonStop = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonStop setFrame:CGRectMake(round((CGRectGetWidth([view bounds]) - 60.0) / 2.0), CGRectGetMaxY([_buttonNext frame]) + 20.0, 60.0, 20.0)];
    [_buttonStop setTitle:@"Stop" forState:UIControlStateNormal];
    [_buttonStop addTarget:self action:@selector(_actionStop:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonStop];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_buttonStop frame]) + 20.0, CGRectGetWidth([view bounds]) - 20.0 * 2.0, 40.0)];
    [_progressSlider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_progressSlider];
    
    _volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_progressSlider frame]) + 20.0, 80.0, 40.0)];
    [_volumeLabel setText:@"Volume:"];
    [view addSubview:_volumeLabel];
    
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX([_volumeLabel frame]) + 10.0, CGRectGetMinY([_volumeLabel frame]), CGRectGetWidth([view bounds]) - CGRectGetMaxX([_volumeLabel frame]) - 10.0 - 20.0, 40.0)];
    [_volumeSlider addTarget:self action:@selector(_actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_volumeSlider];
    
    _audioVisualizer = [[DOUAudioVisualizer alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_volumeSlider frame]), CGRectGetWidth([view bounds]), CGRectGetHeight([view bounds]) - CGRectGetMaxY([_volumeSlider frame]))];
    [_audioVisualizer setBackgroundColor:[UIColor colorWithRed:239.0 / 255.0 green:244.0 / 255.0 blue:240.0 / 255.0 alpha:1.0]];
    [view addSubview:_audioVisualizer];
    
    [self setView:view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [PlayEngine sharedInstance].delegate = self;
    [self refreshView];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [PlayEngine sharedInstance].delegate = nil;
    [_timer invalidate];
    [super viewWillDisappear:animated];
}

#pragma mark - event action

- (void)_actionPlayPause:(id)sender
{
    [[PlayEngine sharedInstance] actionPlayPause];
}

- (void)_actionNext:(id)sender
{
    [[PlayEngine sharedInstance] actionPlayNextSong];
}

- (void)_actionStop:(id)sender
{
    [[PlayEngine sharedInstance] actionStop];
    [self refreshView];
}

- (void)_actionSliderProgress:(id)sender
{
    [[PlayEngine sharedInstance] actionSetCurrentDuration:[_progressSlider value]];
}

- (void)_actionSliderVolume:(id)sender
{
    [PlayEngine setVolume:[_volumeSlider value]];
}

- (void)_timerAction
{
    [self onDurationChange:[PlayEngine sharedInstance].duration andCurrentTime:[PlayEngine sharedInstance].currentTime];
}

#pragma mark - PlayEngineDelegate

- (void)onStatusChange:(DOUAudioStreamerStatus)status
{
    switch (status) {
        case DOUAudioStreamerPlaying:
            [_statusLabel setText:@"playing"];
            [_buttonPlayPause setTitle:@"Pause" forState:UIControlStateNormal];
            break;
        case DOUAudioStreamerPaused:
            [_statusLabel setText:@"paused"];
            [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
            break;
    
        case DOUAudioStreamerIdle:
            [_statusLabel setText:@"idle"];
            [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            [_statusLabel setText:@"finished"];
            [self _actionNext:nil];
            break;
    
        case DOUAudioStreamerBuffering:
            [_statusLabel setText:@"buffering"];
            break;
            
        case DOUAudioStreamerError:
            [_statusLabel setText:@"error"];
            break;
    }
}

- (void)onDurationChange:(NSTimeInterval)duration andCurrentTime:(NSTimeInterval)currentTime
{
    if (duration == 0.0) {
        [_progressSlider setValue:0.0f animated:NO];
    } else {
        [_progressSlider setValue:currentTime/duration animated:YES];
    }
}

- (void)onBufferingRatioReceivedLength:(NSUInteger)receivedLength expectedLength:(NSUInteger)expectedLength bufferingRatio:(double)bufferingRatio downloadSpeed:(NSUInteger)downloadSpeed
{
    [_miscLabel setText:[NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)receivedLength/1024/1024, (double)expectedLength/1024/1024, bufferingRatio*100.0, (double)downloadSpeed/1024/1024]];
}

- (void)onTrackChange:(Track *)currentTrack
{
    if (currentTrack) {
        NSString *title = [NSString stringWithFormat:@"%@ - %@", currentTrack.artist, currentTrack.title];
        [_titleLabel setText:title];
    } else {
        [_titleLabel setText:@""];
    }
}

#pragma mark - private action
- (void)refreshView
{
    [self onTrackChange:[[PlayEngine sharedInstance] currentTrack]];
    [self onStatusChange:[[PlayEngine sharedInstance] status]];
    [self onDurationChange:[[PlayEngine sharedInstance] duration] andCurrentTime:[[PlayEngine sharedInstance] currentTime]];
    [_volumeSlider setValue:[[PlayEngine sharedInstance] volume]];
    DOUAudioStreamer *streamer = [PlayEngine sharedInstance].streamer;
    if (streamer) {
        [self onBufferingRatioReceivedLength:streamer.receivedLength expectedLength:streamer.expectedLength bufferingRatio:streamer.bufferingRatio downloadSpeed:streamer.downloadSpeed];
    }
}

@end

/* vim: set ft=objc fenc=utf-8 sw=2 ts=2 et: */
/*
 *  DOUAudioStreamer - A Core Audio based streaming audio player for iOS/Mac:
 *
 *      https://github.com/douban/DOUAudioStreamer
 *
 *  Copyright 2013-2014 Douban Inc.  All rights reserved.
 *
 *  Use and distribution licensed under the BSD license.  See
 *  the LICENSE file for full text.
 *
 *  Authors:
 *      Chongyu Zhu <i@lembacon.com>
 *
 */

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"
#import "PlayEngine.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [DOUAudioStreamer setOptions:[DOUAudioStreamer options] | DOUAudioStreamerRequireSHA256];

  [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];

  MainViewController *mainViewController = [[MainViewController alloc] initWithStyle:UITableViewStylePlain];
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
  [[self window] setRootViewController:navigationController];

  [[self window] makeKeyAndVisible];

  return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype)
    {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"remote event: play");
            [[PlayEngine sharedInstance] actionPlayPause];
            break;
        case UIEventSubtypeRemoteControlPause:
            NSLog(@"remote event: pause");
            [[PlayEngine sharedInstance] actionPlayPause];
            break;
        case UIEventSubtypeRemoteControlStop:
            NSLog(@"remote event: stop");
            [[PlayEngine sharedInstance] actionStop];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            NSLog(@"remote event: next");
            [[PlayEngine sharedInstance] actionPlayNextSong];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            NSLog(@"remote event: previous");
            [[PlayEngine sharedInstance] actionPlayLastSong];
            break;
        default:
            break;
    }
}

@end

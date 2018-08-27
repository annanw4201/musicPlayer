//
//  playerManager.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-26.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "playerManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface playerManager ()

@end


@implementation playerManager
@synthesize playerItem = _playerItem;
@synthesize player = _player;

static playerManager *_musicManager = nil;

// get manager instance
+ (playerManager *)musicManager {
    @synchronized( [playerManager class] ) {
        if (!_musicManager) {
            _musicManager = [[self alloc] init];
            return _musicManager;
        }
    }
    return nil;
}

- (Boolean) play:(NSString *)fileName {
    if (_player != NULL) {
        if ([_player rate] == 0) {
            [[self player] play];
            return YES;
        }
        else {
            [self pause];
            return NO;
        }
    }
    else {
        NSLog(@"manager play -- name: \"%@\"!", fileName);
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@".mp3"];
        NSLog(@"url is %@", url);
        if (url) {
            _playerItem = [[AVPlayerItem alloc] initWithURL:url];
            _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
            [[self player] play];
            return YES;
        }
        return NO;
    }
}

- (void) pause {
    [_player pause];
}

- (AVPlayerItem *) currentPlayerItem {
    return [self playerItem];
}

- (void) didfinishPlaying {
    _playerItem = nil;
    _player = nil;
}

@end

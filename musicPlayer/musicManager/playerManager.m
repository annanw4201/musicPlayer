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
#import "songModel.h"

@interface playerManager ()
@property (nonatomic, strong) songModel *currentSongModel;
@end


@implementation playerManager
@synthesize playerItem = _playerItem;
@synthesize player = _player;

static playerManager *_musicManager = nil;

// get manager instance
+ (playerManager *)musicManager {
        if (!_musicManager) {
            _musicManager = [[self alloc] init];
            return _musicManager;
        }
    
    return nil;
}

// load the song
- (songModel *) loadMusic:(NSString *)fileName {
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@".mp3"];
    if (url) {
        _currentSongModel = [[songModel alloc] init];
        _currentSongModel.singer = @"邓紫棋";
        _currentSongModel.songName = @"泡沫";
        
        _playerItem = [[AVPlayerItem alloc] initWithURL:url];
        _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    }
    return _currentSongModel;
}

// Play the song
- (Boolean) play:(NSString *)fileName {
    if (_player) {
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
        [self loadMusic:fileName];
        [_player play];
        return YES;
    }
}

// pause the song
- (void) pause {
    [_player pause];
}

// get current playing playerItem
- (AVPlayerItem *) currentPlayerItem {
    return [self playerItem];
}

// handle after finishing the song
- (void) didfinishPlaying {
    _playerItem = nil;
    _player = nil;
}

// get current playing player
- (AVPlayer *) currentPlayer {
    return [self player];
}

@end

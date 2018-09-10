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
#import "fileFetcher.h"
#import <MediaPlayer/MediaPlayer.h>
#import "lrcModel.h"

@interface playerManager ()
@property (nonatomic, strong) songModel *currentSongModel;
@property (nonatomic, strong) NSArray *songModelList;
@property (nonatomic, assign) NSUInteger songIndex;
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

- (void)getLocalSongs {
    NSMutableArray *modelList = [[NSMutableArray alloc] init];
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
    NSArray *itemsInMedia = [mediaQuery items];
    for (MPMediaItem *item in itemsInMedia) {
        NSString *songName = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString *singerName = [item valueForProperty:MPMediaItemPropertyArtist];
        NSString *songURLString = [[item valueForProperty:MPMediaItemPropertyAssetURL] absoluteString];
        NSURL *songURL = [NSURL URLWithString:songURLString];
        NSString *lyric = [item valueForProperty:MPMediaItemPropertyLyrics];
        UIImage *songArtWork = [[item valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(350, 350)];
        NSString *songAlbumName = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        
        songModel *song = [[songModel alloc] init];
        song.songName = songName;
        song.songMPArtWork = songArtWork;
        song.singer = singerName;
        song.songURL = songURL;
        song.songAlbumName = songAlbumName;
        song.lrcModel = [[lrcModel alloc] init];
        [modelList addObject:song];
        //        NSLog(@"title: %@", songName);
        //        NSLog(@"songName: %@", singerName);
        //        NSLog(@"songURL: %@", songURLString);
        //        NSLog(@"songArtWork: %@", songArtWork);
        //        NSLog(@"lyric: %@", lyric);
    }
    NSLog(@"songmodellist size: %lu", (unsigned long)[self.songModelList count]);
    self.songModelList = modelList;
    self.songIndex = 0;
}

// load the song
- (songModel *) loadMusic:(NSString *)fileName {
    
    //    self.songModelList = [fileFetcher querySongList];
    //    NSDictionary *songData = [[self.songModelList objectAtIndex:0] objectForKey:@"data"];
    //    NSString *songmid = [songData objectForKey:@"songmid"];
    //    NSURL *url = [fileFetcher urlOfSongmid:songmid];
    //    if (fileName) url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@".mp3"];
    
    if ([self.songModelList count] > 0) {
        songModel *song = [self.songModelList objectAtIndex:self.songIndex];
        if (song) {
            //        self.currentSongModel = [[songModel alloc] init];
            //        self.currentSongModel.songmid = songmid;
            //        self.currentSongModel.songName = [songData objectForKey:@"songname"];
            //        self.currentSongModel.songAlbumName = [songData objectForKey:@"albumname"];
            //        self.currentSongModel.singer = [[songData valueForKeyPath:@"singer.name"] firstObject];
            //        if (fileName) self.currentSongModel.lrcName = fileName;
            
            NSURL *url = song.songURL;
            if (url) {
                self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
                self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
                self.currentSongModel = song;
            }
        }
    }
    return self.currentSongModel;
}

// Play the song
- (Boolean) play:(NSString *)fileName {
    if (_player) {
        if ([_player rate] == 0) {
            NSLog(@"manager, player rate 0");
            [[self player] play];
            return YES;
        }
        else {
            NSLog(@"manager, player rate 1");
            [self pause];
            return NO;
        }
    }
    else {
        return NO;
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

- (void)nextSong {
    [self didfinishPlaying];
    self.songIndex == [self.songModelList count] - 1 ? self.songIndex = 0 : self.songIndex++;
}

- (void)lastSong {
    [self didfinishPlaying];
    self.songIndex == 0 ? self.songIndex = [self.songModelList count] - 1 : self.songIndex--;
}
//
@end

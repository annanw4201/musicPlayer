//
//  playerManager.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-26.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVPlayer;
@class AVPlayerItem;
@class songModel;

@interface playerManager : NSObject
+ (playerManager *)musicManager;
- (Boolean) play: (NSString *)fileName;
- (void) pause;
- (AVPlayerItem *) currentPlayerItem;
- (AVPlayer *) currentPlayer;
- (void) didfinishPlaying;
- (songModel *) loadMusic:(songModel *)song;
- (void)getLocalSongs;
- (void)nextSong;
- (void)lastSong;
- (BOOL)enableRandomSong;
- (NSArray *)getSongModelList;
- (void)setSongIndex:(NSUInteger)songIndex;
- (NSInteger)getSongIndex;
- (songModel *)getCurrentSongModel;
@end


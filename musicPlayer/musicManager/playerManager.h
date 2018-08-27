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

@interface playerManager : NSObject
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;

+ (playerManager *)musicManager;
- (Boolean) play: (NSString *)fileName;
- (void) pause;
- (AVPlayerItem *) currentPlayerItem;
- (void) didfinishPlaying;
@end


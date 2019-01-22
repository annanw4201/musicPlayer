//
//  songModel.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-30.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "songModel.h"
#import "lrcModel.h"

@interface songModel()

@end

@implementation songModel
- (id)init {
    self = [super init];
    if (self) {
        self.songName = @"Unknown Title";
        self.songAlbumName = @"Unknown Album";
        self.singer = @"Unknown Singer";
        self.lrcModel = [[lrcModel alloc] init];
    }
    return self;
}

@end

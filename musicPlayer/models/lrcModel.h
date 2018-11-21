//
//  lrcModel.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-31.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lrcModel : NSObject

- (void)setupWithFile: (NSString *)fileName;
- (id)initWithFile: (NSString *)file;
- (id)init;
- (NSString *)lyricForTimeInSec: (float)time;
- (NSArray *)getLyricArr;
- (NSString *)getSongName;
- (NSString *)getSinger;
- (NSString *)getAlbumName;
- (NSInteger)getCurrentTimeIndex;
@end

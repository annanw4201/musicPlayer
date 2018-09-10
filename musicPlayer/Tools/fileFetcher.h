//
//  fileFetcher.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-30.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fileFetcher : NSObject
+ (NSArray *)querySongList;
+ (NSString *)querySongmid:(NSDictionary *)songData;
+ (NSURL *)urlOfSongmid:(NSString *)songmid;
@end

//
//  cache.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-11-23.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface cache : NSObject
+ (NSString *)retrieveLrc:(NSString *)songName withSinger:(NSString *)singerName;
@end

NS_ASSUME_NONNULL_END

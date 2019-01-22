//
//  fileFetcher.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-30.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fileFetcher : NSObject
+ (NSURL *)urlOfLrclink:(NSString *)lrclink;
+ (NSURL *)urlOfLrc:(NSString *)title withSinger:(NSString *)singer;
+ (NSData *)lrcData:(NSString *)title withSinger:(NSString *)singer;
+ (NSArray *)listOfSongs:(NSString *)title withSinger:(NSString *)singer;
@end

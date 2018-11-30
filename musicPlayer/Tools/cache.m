//
//  cache.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-11-23.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "cache.h"
#import "fileFetcher.h"

#define lrcPath @"lrcDir"

@implementation cache

+ (void)saveLrc:(NSString *)songName withSinger:(NSString *)singerName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheRootPath = [[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    NSString *lrcDir = [cacheRootPath stringByAppendingPathComponent:lrcPath];
    Boolean lrcDirExists = [fileManager isReadableFileAtPath:lrcDir];
    if (!lrcDirExists) {
        NSLog(@"new lrc directory created");
        [fileManager createDirectoryAtPath:lrcDir withIntermediateDirectories:NO attributes:NULL error:NULL];
    }
    NSString *pathToSave = [lrcDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lrc", songName]];
    Boolean lrcExists = [fileManager isReadableFileAtPath:pathToSave];
    if (!lrcExists) {
        NSLog(@"lrc not exists, %@", songName);
        NSURL *lrcURL = [fileFetcher urlOfLrc:songName withSinger:singerName];
        NSData *data = [NSData dataWithContentsOfURL:lrcURL];
        //NSData *data = [fileFetcher lrcData:songName withSinger:singerName];
        [data writeToFile:pathToSave atomically:YES];
    }
}

+ (NSString *)retrieveLrc:(NSString *)songName withSinger:(NSString *)singerName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheRootPath = [[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    NSString *lrcDir = [cacheRootPath stringByAppendingPathComponent:lrcPath];
    NSString *lrcPathToRetrieve = [lrcDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lrc", songName]];
    if (![fileManager isReadableFileAtPath:lrcPathToRetrieve]) {
        [self saveLrc:songName withSinger:singerName];
    }
    NSString *lrcData = [NSString stringWithContentsOfFile:lrcPathToRetrieve encoding:NSUTF8StringEncoding error:nil];
    return lrcData;
}
@end

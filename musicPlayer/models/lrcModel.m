//
//  lrcModel.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-31.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "lrcModel.h"
#define debug false

@interface lrcModel ()
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *singer;
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, strong) NSArray *timeArr;
@property (nonatomic, strong) NSArray *lyricArr;
@property (nonatomic) NSInteger currentTimeIndex;
@property (nonatomic, copy) NSString *currentLyric;
@end

@implementation lrcModel

- (id)init {
    self = [super init];
    if (self) {
        _songName = @"Unknown Title";
        _singer = @"Unknown Singer";
        _albumName = @"Unknown Album";
        _currentLyric = @"No Lyric";
        _currentTimeIndex = 0;
        _timeArr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:0.0], nil];
        _lyricArr = [[NSMutableArray alloc] initWithObjects:@"No Lyric", nil];
    }
    return self;
}

- (id)initWithFile:(NSString *)fileName {
    self = [super init];
    if (self) {
        _songName = @"Unknown Title";
        _singer = @"Unknown Singer";
        _albumName = @"Unknown Album";
        _currentLyric = @"No Lyric";
        _currentTimeIndex = 0;
        [self setupWithFile:fileName];
    }
    return self;
}

// convert time string "01:06.06" into seconds
- (NSNumber *)lrcTime: (NSString *)timeStr {
    float time = 0.0;
    if ([timeStr isEqualToString:@""]) return [NSNumber numberWithFloat:0.0];
    NSString *timeStrFormatted = [timeStr substringFromIndex:1];
    if (debug) NSLog(@"time formatted: %@", timeStrFormatted);
    NSArray *timeArr = [timeStrFormatted componentsSeparatedByString:@":"];
    float min = [[timeArr firstObject] floatValue];
    NSString *secStr = [timeArr lastObject];
    NSArray *secArr = [secStr componentsSeparatedByString:@"."];
    float sec = [[secArr firstObject] floatValue] + [[secArr lastObject] floatValue] / 100;
    time = min * 60 + sec;
    return [NSNumber numberWithFloat:time];
}

// build time array with corresponding lyric array using passing file
- (void)setupWithFile:(NSString *)fileName {
    NSMutableArray *mutableTimeArr = [[NSMutableArray alloc] init];
    NSMutableArray *mutableLyricArr = [[NSMutableArray alloc] init];
    
    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *lrcStr = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lrcArr = [lrcStr componentsSeparatedByString:@"\n"];
    if (debug) NSLog(@"%@", lrcStr);
    for (NSString *line in lrcArr) {
        if ([line hasPrefix:@"[ti:"] || [line hasPrefix:@"[ar:"] || [line hasPrefix:@"[al:"]) {
            NSArray *lineArr = [line componentsSeparatedByString:@":"];
            NSString *lineStr = [lineArr lastObject];
            if ([line hasPrefix:@"[ti:"]) _songName = [lineStr substringToIndex:[lineStr length] - 1];
            if ([line hasPrefix:@"[ar:"]) _singer = [lineStr substringToIndex:[lineStr length] - 1];
            if ([line hasPrefix:@"[al:"]) _albumName = [lineStr substringToIndex:[lineStr length] - 1];
        }
        else {
            NSArray *lineArr = [line componentsSeparatedByString:@"]"];
            NSString *timeStr = [lineArr firstObject];
            NSString *lyric = [lineArr lastObject];
            NSNumber *lyricTime = [self lrcTime:timeStr];
            [mutableTimeArr addObject:lyricTime];
            [mutableLyricArr addObject:lyric];
        }
        
    }
    _lyricArr = mutableLyricArr;
    _timeArr = mutableTimeArr;
}

// retrieve the lyric for a specific time in seconds
- (NSString *) lyricForTimeInSec:(float)time {
    NSInteger index = 0;
    if (_timeArr && [_timeArr count] > 0) {
        for (; index < [_timeArr count]; ++index) {
            float timeItemFloatVal = [[_timeArr objectAtIndex:index] floatValue];
            if (time < timeItemFloatVal) {
                --index;
                break;
            }
        }
        index = index >= [_lyricArr count] ? [_lyricArr count] - 1 : index;
        _currentLyric = [_lyricArr objectAtIndex:index];
        _currentTimeIndex = index;
    }
    return _currentLyric;
}

#pragma getters
// getters
- (NSArray *)getLyricArr {
    return _lyricArr;
}

- (NSString *)getSongName {
    return _songName;
}

- (NSString *)getSinger {
    return _singer;
}

- (NSString *)getAlbumName {
    return _albumName;
}

- (NSInteger)getCurrentTimeIndex {
    return _currentTimeIndex;
}

@end

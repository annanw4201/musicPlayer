//
//  fileFetcher.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-30.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "fileFetcher.h"

#define APIROOT @"http://ws.audioscrobbler.com/2.0/"
#define APIMethod(method) [NSString stringWithFormat:@"?method=%@", method]
#define APIMethodName(methodClass, methodSpecificName) [NSString stringWithFormat:@"&%@=%@", methodClass, methodSpecificName]
#define APIKEY @"&api_key=25842f51f0c6dca8d94d25d68473179e"
#define APIFormat @"&format=json"

// lrc api from Baidu music
#define LRCAPI(name) [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.lrcys&format=json&query=%@", name]
#define getLrcLink(lrcLinkStr) [NSString stringWithFormat:@"http://qukufile2.qianqian.com/%@", lrcLinkStr]
#define Search(name) [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.common&query=%@&page_size=8&page_no=1&format=json", name]

#define musixmatchROOT @"http://api.musixmatch.com/ws/1.1/"
#define musixmatchKEY @"232872b5cd3665b9035358233752891d"
#define musixmatchSearchTrack(singer, title) [NSString stringWithFormat:@"%@track.search?q_artist=%@&q_track=%@&page_size=10&page=1&s_track_rating=desc&apikey=%@", musixmatchROOT, singer, title, musixmatchKEY]
#define musixmatchLyricMatcher(singer, title) [NSString stringWithFormat:@"%@matcher.lyrics.get?q_track=%@&q_artist=%@&apikey=%@", musixmatchROOT, singer, title, musixmatchKEY]


@implementation fileFetcher

+ (NSString *)filterString:(NSString *)str withRegexStr:(NSString *)regexStr {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    str = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@""];
    return str;
}

+ (NSURL *)urlOfLrclink:(NSString *)lrclink {
    return lrclink ? [NSURL URLWithString:getLrcLink(lrclink)] : nil;
}

+ (NSURL *)urlOfLrc:(NSString *)title withSinger:(NSString *)singer {
    title = [self filterString:title withRegexStr:@"( *[\\（]+.*[\\）]+.*)+"];
    NSString *query = Search(title);
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSArray *songList = [result objectForKey:@"song_list"];
    NSString *lrcLinkStr = nil;
    if ([songList isKindOfClass:[NSArray class]]) {
        for (NSDictionary *songDict in songList) {
            NSString *title = [songDict objectForKey:@"title"];
            NSString *author = [songDict objectForKey:@"author"];
            if ([title rangeOfString:title].location != NSNotFound || [author rangeOfString:singer].location != NSNotFound) {
                lrcLinkStr = [songDict objectForKey:@"lrclink"];
                break;
            }
        }
    }
    return lrcLinkStr != nil ? [NSURL URLWithString:getLrcLink(lrcLinkStr)] : nil;
}

+ (NSArray *)listOfSongs:(NSString *)title withSinger:(NSString *)singer {
    title = [self filterString:title withRegexStr:@"( *[\\（]+.*[\\）]+.*)+"];
    NSString *query = Search(title);
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSArray *songList = [result objectForKey:@"song_list"];
    if ([songList isKindOfClass:[NSArray class]]) {
        return songList;
    }
    else {
        return nil;
    }
}

+ (NSData *)lrcData:(NSString *)title withSinger:(NSString *)singer {
    NSString *query = musixmatchLyricMatcher(singer, title);
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSDictionary *messageBody = [[result objectForKey:@"message"] objectForKey:@"body"];
    NSData *lyricData = nil;
    if (messageBody != nil && [messageBody isKindOfClass:[NSDictionary class]]) {
        NSDictionary *lyrics = [messageBody objectForKey:@"lyrics"];
        if (lyrics != nil && [lyrics isKindOfClass:[NSDictionary class]]) {
            NSString *lyricBody = [lyrics objectForKey:@"lyrics_body"];
            lyricData = [lyricBody dataUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"lyricData:%@", lyricData);
        }
    }
    return lyricData;
}

@end

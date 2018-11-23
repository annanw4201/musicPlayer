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
#define Search(name) [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.common&query=%@&page_size=30&page_no=1&format=json", name]

@implementation fileFetcher

+ (NSURL *)urlOfLrc:(NSString *)lrcname {
    NSString *query = LRCAPI(lrcname);
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    
    id lrcList = [results objectForKey:@"lrcys_list"];
    NSDictionary *firstLrcDict = nil;
    if ([lrcList isKindOfClass:[NSArray class]]) {
        firstLrcDict = [lrcList firstObject];
    }
    
    return firstLrcDict != nil ? [NSURL URLWithString:[firstLrcDict objectForKey:@"lrclink"]] : nil;
}

+ (NSURL *)urlOfLrc:(NSString *)songName withSinger:(NSString *)singer {
    NSString *query = Search(songName);
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
            if ([title rangeOfString:songName].location != NSNotFound || [author rangeOfString:singer].location != NSNotFound) {
                lrcLinkStr = [songDict objectForKey:@"lrclink"];
                break;
            }
        }
    }
    return lrcLinkStr != nil ? [NSURL URLWithString:getLrcLink(lrcLinkStr)] : nil;
}

@end

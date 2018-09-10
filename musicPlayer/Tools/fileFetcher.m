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


#define NewMusicRankingList @"https://c.y.qq.com/v8/fcg-bin/fcg_v8_toplist_cp.fcg?g_tk=5381&uin=0&format=json&inCharset=utf-8&outCharset=utf-8¬ice=0&platform=h5&needNewCode=1&tpl=3&page=detail&type=top&topid=27&_=1519963122923"
#define songDataURLString(songmid) [NSString stringWithFormat:@"http://ws.stream.qqmusic.qq.com/C100%@.m4a?fromtag=0&guid=126548448", songmid]
#define lyricAPI(songid) [NSString stringWithFormat:@"http://music.qq.com/miniportal/static/lyric/%@/%@.xml",  [NSNumber numberWithInt:songid % 100], [NSNumber numberWithInt:songid]]]

@implementation fileFetcher

/*
// using last.fm API to get music data
+ (void)tracksFromMethod:(NSString *)method inClass:(NSString *)methodClass using:(NSString *)specificName {
    NSString *query = [NSString stringWithFormat:@"%@%@%@%@%@", APIROOT, APIMethod(method), APIMethodName(methodClass, specificName), APIKEY, APIFormat];
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // NSLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"query:%@", query);
    NSLog(@"%@",jsonData);
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    // NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    NSLog(@"%@",results);
}
*/

+ (NSArray *)querySongList {
    NSString *query = NewMusicRankingList;
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSArray *songList = [results objectForKey:@"songlist"];
    return songList;
}

+ (NSString *)querySongmid:(NSDictionary *)songData {
    return [songData objectForKey:@"songmid"];
}

+ (NSURL *)urlOfSongmid:(NSString *)songmid {
    return [NSURL URLWithString:songDataURLString(songmid)];
}


@end

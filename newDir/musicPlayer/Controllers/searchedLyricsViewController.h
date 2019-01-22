//
//  searchedLyricsTableViewController.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-11-26.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol searchedLyricsDelegate <NSObject>

- (void)updateCurrentSongLrcModel:(NSString *)lrclink;

@end


@interface searchedLyricsViewController : UIViewController
- (void)setSongList:(NSArray *)songList;
@property (nonatomic, weak) IBOutlet id<searchedLyricsDelegate>delegate;
@end

NS_ASSUME_NONNULL_END

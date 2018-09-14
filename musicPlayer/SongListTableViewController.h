//
//  SongListTableViewController.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-09-11.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol songListTableViewDelegate <NSObject>
- (void)setToSongIndex: (NSInteger)index;
- (NSInteger)getSongIndex;
@end

@interface SongListTableViewController : UIViewController
- (void)update;
- (void)setSongModelList:(NSArray *)songModelList;
@property (nonatomic, weak)id<songListTableViewDelegate>songListDelegate;
@end

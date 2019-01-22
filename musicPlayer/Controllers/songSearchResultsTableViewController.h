//
//  songSearchResultsTableViewController.h
//  musicPlayer
//
//  Created by Wong Tom on 2019-01-14.
//  Copyright © 2019 Wang Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class songModel;
@class songSearchResultsTableViewController;

@protocol songSearchResultsTableViewControllerDelegate <NSObject>

- (void)selectSong:(songModel *)song from:(songSearchResultsTableViewController *)viewController;

@end

@interface songSearchResultsTableViewController : UITableViewController
- (void)setFilteredSongs:(NSArray *)filteredSongs;
@property(nonatomic, weak)id<songSearchResultsTableViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END

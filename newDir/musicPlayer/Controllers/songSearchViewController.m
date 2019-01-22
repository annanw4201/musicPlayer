//
//  songSearchViewController.m
//  musicPlayer
//
//  Created by Wong Tom on 2019-01-13.
//  Copyright © 2019 Wang Tom. All rights reserved.
//

#import "songSearchViewController.h"
#import "../Controllers/songSearchResultsTableViewController.h"
#import "../Controllers/PlayerViewController.h"
#import "../Models/songModel.h"

@interface songSearchViewController ()<UISearchResultsUpdating, songSearchResultsTableViewControllerDelegate>
@property (nonatomic, strong) NSArray *data;
@end

@implementation songSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // configure search controller
    [self configureSearchController];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PlayerViewController *playerVC = (PlayerViewController *)[self.tabBarController.viewControllers lastObject];
    self.data = [playerVC getSongs];
}

- (void)setData:(NSArray *)data {
    if (_data != data) {
        _data = data;
    }
}

- (void)configureSearchController {
    UINavigationController *searchResultsNavigationController = [[UIStoryboard storyboardWithName:@"SongSearchResults" bundle:nil] instantiateInitialViewController];
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsNavigationController];
    searchController.searchResultsUpdater = self;
    searchController.obscuresBackgroundDuringPresentation = false;
    searchController.searchBar.placeholder = @"Type to search";
    self.definesPresentationContext = YES;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
        songSearchResultsTableViewController *searchResultsVC = (songSearchResultsTableViewController *)searchResultsNavigationController.topViewController;
        searchResultsVC.delegate = self;
    }
    else {
        // Fallback on earlier versions
        
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *text = searchController.searchBar.text;
    NSLog(@"%@: filter for search text: %@", self.class, text);
    if (!text) return;
    else {
        // filter the songs
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            songModel *song = (songModel *)evaluatedObject;
            return [song.songName containsString:text] || [song.singer containsString:text];
        }];
        NSArray *filteredSongs = [self.data filteredArrayUsingPredicate:predicate];
        
        // set the filtered songs of the song search results table view controller
        if (@available(iOS 11.0, *)) {
            UINavigationController *searchResultsNavigationController = (UINavigationController *)self.navigationItem.searchController.searchResultsController;
            if (searchResultsNavigationController) {
                songSearchResultsTableViewController *searchResultsVC = (songSearchResultsTableViewController *)searchResultsNavigationController.topViewController;
                [searchResultsVC setFilteredSongs:filteredSongs];
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - songSearchResultsTableViewControllerDelegate
- (void)selectSong:(songModel *)song from:(songSearchResultsTableViewController *)viewController {
    PlayerViewController *playerVC = (PlayerViewController *)[self.tabBarController.viewControllers lastObject];
    [playerVC prepareToPlay:song];
    [playerVC play:nil];
}

@end

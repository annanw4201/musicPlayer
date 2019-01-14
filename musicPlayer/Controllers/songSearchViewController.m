//
//  songSearchViewController.m
//  musicPlayer
//
//  Created by Wong Tom on 2019-01-13.
//  Copyright © 2019 Wang Tom. All rights reserved.
//

#import "songSearchViewController.h"

@interface songSearchViewController ()<UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *filteredData;
@end

@implementation songSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.obscuresBackgroundDuringPresentation = false;
    searchController.searchBar.placeholder = @"Type to search";
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
    }
    else {
        // Fallback on earlier versions
        
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *text = searchController.searchBar.text;
    if (!text) return;
    else {
        NSLog(@"%@", text);
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

@end

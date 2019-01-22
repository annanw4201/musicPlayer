//
//  searchedLyricsTableViewController.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-11-26.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "searchedLyricsViewController.h"

@interface searchedLyricsViewController () <UITableViewDelegate, UITableViewDataSource>
@property(strong, nonatomic) NSArray *songList;
@property(weak, nonatomic) UITableView *tableView;
@end

@implementation searchedLyricsViewController

// As the controller is complex we need to tell how to decode this controller
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self respondsToSelector:@selector(setTransitioningDelegate:)]) {
            self.modalPresentationStyle = UIModalPresentationCustom;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UITableView *lyricsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, screenBounds.size.height * 0.5, screenBounds.size.width, screenBounds.size.height * 0.5)];
    [lyricsTableView registerNib:[UINib nibWithNibName:@"songListCellNib" bundle:nil] forCellReuseIdentifier:@"songListCell"];
    [lyricsTableView setBackgroundColor:[UIColor darkGrayColor]];
    [lyricsTableView.layer setCornerRadius:10.0];
    [lyricsTableView setDelegate:self];
    [lyricsTableView setDataSource:self];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tapOnBackGroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPresentationVC:)];
    [backgroundView addGestureRecognizer:tapOnBackGroundView];
    
    self.tableView = lyricsTableView;
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backgroundView];
    [self.view addSubview:self.tableView];
}

- (void)setSongList:(NSArray *)songList {
    if (_songList != songList) {
        _songList = songList;
    }
    [self.tableView reloadData];
}

- (void)dismissPresentationVC: (UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songList ? [self.songList count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songListCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell setBackgroundColor:[UIColor clearColor]];
    NSDictionary *songDict = [self.songList objectAtIndex:[indexPath row]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    NSString *title = [songDict objectForKey:@"title"] != [[NSNull alloc] init] ? [songDict objectForKey:@"title"] : @"Unknown Title";
    NSString *author = [songDict objectForKey:@"author"] != [[NSNull alloc] init] ? [songDict objectForKey:@"author"] : @"Unknown Author";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<em>|<\\/em>)" options:NSRegularExpressionCaseInsensitive error:nil];
    title = [regex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, [title length]) withTemplate:@""];
    author = [regex stringByReplacingMatchesInString:author options:0 range:NSMakeRange(0, [author length]) withTemplate:@""];
    
    NSLog(@"title: %@", title);
    NSLog(@"author: %@", author);
    [cell.textLabel setText:title];
    [cell.detailTextLabel setText:author];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *songDict = [self.songList objectAtIndex:[indexPath row]];
    NSString *lrclink = [songDict objectForKey:@"lrclink"];
    [self.delegate updateCurrentSongLrcModel:lrclink];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

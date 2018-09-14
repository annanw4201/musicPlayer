//
//  SongListTableViewController.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-09-11.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "SongListTableViewController.h"
#import "songModel.h"
#import "playerManager.h"

@interface SongListTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSArray *songModelList;
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation SongListTableViewController

- (id)init {
    self = [super init];
    if (self) {
        [self.view setAlpha:0.85];
        [self setModalPresentationStyle:UIModalPresentationCustom];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        UITableView *songListView = [[UITableView alloc] initWithFrame:CGRectMake(0, screenBounds.size.height * 0.5, screenBounds.size.width, screenBounds.size.height * 0.5)];
        [songListView registerNib:[UINib nibWithNibName:@"songListCellNib" bundle:nil] forCellReuseIdentifier:@"songListCell"];
        //[songListView registerClass:[UITableViewCell self] forCellReuseIdentifier:@"songListCell"];
        [songListView setBackgroundColor:[UIColor darkGrayColor]];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        UITapGestureRecognizer *tapOnBackGroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [backgroundView addGestureRecognizer:tapOnBackGroundView];
        
        
        [songListView setDataSource:self];
        [songListView setDelegate:self];
        self.tableView = songListView;
        [[self view] addSubview:backgroundView];
        [[self view] addSubview:self.tableView];
    }
    return self;
}

- (void)dismiss:(UITapGestureRecognizer *)sender {
    if (self) [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update {
    NSLog(@"update table vc");
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.songListDelegate getSongIndex] inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)setSongModelList:(NSArray *)songModelList {
    _songModelList = songModelList;
    [self update];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.songModelList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songListCell" forIndexPath:indexPath];
    // Configure the cell...
    [cell setBackgroundColor:[UIColor clearColor]];
    songModel *song = [self.songModelList objectAtIndex:[indexPath row]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setText:song.songName];
    [cell.detailTextLabel setText:song.singer];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (self.songListDelegate.getSongIndex == [indexPath row]) {
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell setBackgroundColor:[UIColor lightGrayColor]];
    }
    return cell;
}

- (void)tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    NSLog(@"tap on row: %ld", (long)[indexPath row]);
    // resume state of previous selected cell
    NSIndexPath *preSelectedCellIndexPath = [NSIndexPath indexPathForItem:[self.songListDelegate getSongIndex] inSection:0];
    UITableViewCell *preSelectedCell = [self.tableView cellForRowAtIndexPath:preSelectedCellIndexPath];
    [preSelectedCell.textLabel setTextColor:[UIColor whiteColor]];
    [preSelectedCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    [preSelectedCell setBackgroundColor:[UIColor clearColor]];
    
    // send current selected cell to playerViewController delegate for playing
    [self.songListDelegate setToSongIndex:[indexPath row]];
    
    // update new selected cell state
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    [cell setBackgroundColor:[UIColor lightGrayColor]];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

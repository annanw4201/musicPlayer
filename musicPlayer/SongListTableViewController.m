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
@property (nonatomic, weak)UITableView *tableView;
@end

@implementation SongListTableViewController

- (id)init {
    self = [super init];
    if (self) {
        [self.view setAlpha:0.85];
        [self setModalPresentationStyle:UIModalPresentationCustom];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        UITableView *songListView = [[UITableView alloc] initWithFrame:CGRectMake(0, screenBounds.size.height * 0.5, screenBounds.size.width, screenBounds.size.height * 0.5)];
        [songListView registerClass:[UITableViewCell self] forCellReuseIdentifier:@"songListCell"];
        [songListView setBackgroundColor:[UIColor lightGrayColor]];
        
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

- (void)setSongModelList:(NSArray *)songModelList {
    _songModelList = songModelList;
    [self.tableView reloadData];
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
    [cell.textLabel setText:song.songName];
    [cell.detailTextLabel setText:song.singer];
    
    return cell;
}

- (void)tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    NSLog(@"tap on row: %ld", (long)[indexPath row]);
    [self.delegate setToSongIndex:[indexPath row]];
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

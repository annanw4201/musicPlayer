//
//  lyricScrollView.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-09-02.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "lyricScrollView.h"

// for register cell class for scroll view
#define cellIdentifier @"lyricCell"

@interface lyricScrollView () <UITableViewDataSource>
@property (nonatomic, weak) UITableView *lrcTableView;
@property (nonatomic, strong) NSArray *lyricArr;
@property (nonatomic) NSInteger currentLyricIndex;
@end

@implementation lyricScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setup];
    return self;
}

- (id)init {
    self = [super init];
    if (self) [self setup];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) [self setup];
    return self;
}

- (void)setup {
    _currentLyricIndex = 0;
    [self setShowsHorizontalScrollIndicator:NO];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    // get lyric scroll view's frame position, and set the lyric table view at the correct position
    CGRect lrcTableViewFrame = CGRectMake(screenBounds.size.width, -self.frame.origin.y, screenBounds.size.width, self.bounds.size.height);
    UITableView *lyricTableView = [[UITableView alloc] initWithFrame:lrcTableViewFrame];
    
    [lyricTableView setDataSource:self];
    [lyricTableView registerClass:[UITableViewCell self] forCellReuseIdentifier:cellIdentifier];
    [self addSubview:lyricTableView];
    _lrcTableView = lyricTableView;
    NSLog(@"lyricScrollView:%@", _lrcTableView);
}

// set and configure table view (when put setting codes inside setup,
//  no updates to tableView since the views are not layouted)
- (void)layoutSubviews {
    [super layoutSubviews];
    [_lrcTableView setBackgroundColor:[UIColor clearColor]];
    [_lrcTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)setLrcArr:(NSArray *)lrcArr {
    NSLog(@"lyricScrollView:setLrcArr, Size: %lu", (unsigned long)[lrcArr count]);
    _lyricArr = lrcArr;
    [_lrcTableView reloadData];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

// scroll the table view to the specified row (must reload tableView first, or won't work)
- (void)scrollToRow:(NSInteger)row {
    if (row != _currentLyricIndex) {
        [self.lrcTableView reloadData];
        NSIndexPath *currentTimeRow = [NSIndexPath indexPathForRow:row inSection:0];
        [self.lrcTableView scrollToRowAtIndexPath:currentTimeRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.currentLyricIndex = row;
        NSLog(@"lyricScrollView:scroll to row: %ld", (long)row);
    }
}

#pragma tableViewDelegate
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([indexPath row] == _currentLyricIndex) {
        [cell.textLabel setFont:[UIFont systemFontOfSize:20]];
        [cell.textLabel setTextColor:[UIColor greenColor]];
    } // if at current lyric, zoom in
    else {
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    } // not at current lyric, regualr font size
    [cell.textLabel setNumberOfLines:0]; // the lyric will be fully displayed
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setText:[_lyricArr objectAtIndex:[indexPath row]]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowNum = 0;
    rowNum = [_lyricArr count];
    return rowNum;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end

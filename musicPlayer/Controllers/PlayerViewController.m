//
//  ViewController.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-22.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "../musicManager/playerManager.h"
#import "../Models/songModel.h"
#import "../Models/lrcModel.h"
#import "lyricScrollView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "../Tools/fileFetcher.h"
#import "searchedLyricsViewController.h"

#define debug true

@interface PlayerViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, searchedLyricsDelegate>
// back ground image
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

// author name label
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;

// music title name label
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;

// song image view
@property (weak, nonatomic) IBOutlet UIImageView *songImageView;

// LRC label
@property (weak, nonatomic) IBOutlet UILabel *LRCLabel;

// lyric scroll view
@property (weak, nonatomic) IBOutlet lyricScrollView *lyricScrollView;

// player control
@property (weak, nonatomic) IBOutlet UIButton *randomButton;
@property (weak, nonatomic) IBOutlet UIButton *lastSongButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *nextSongButton;
@property (weak, nonatomic) IBOutlet UISlider *songSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *songListButton;

// player model
@property (weak, nonatomic) playerManager *playerManager;
@property (weak, nonatomic) lrcModel *currentLrcModel;

// timer
@property (weak, nonatomic) NSTimer *songSliderTimer;
@property (weak, nonatomic) CADisplayLink *lrcLabelTimer;

// songListTableView
@property (weak, nonatomic) UIView *songModelListBackgroundView;
@property (weak, nonatomic) UITableView *songModelListTableView;
@property (weak, nonatomic) NSArray *songModelListArray;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    if (debug) NSLog(@"PlayerViewController:view did load");
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // update status bar style to be what's set in preferredStatusBarStyle
    [self setNeedsStatusBarAppearanceUpdate];
    
    // song slider setup
    [self songSliderSetup];
    
    // lrc label setup
    [self setupLrcLabel];
    
    // lyric scroll view setup
    [self setupLyricScrollView];
    
    // setup player manager
    if (!self.playerManager) self.playerManager = [playerManager musicManager];
    [self.playerManager getLocalSongs];
    [self.playerManager loadMusic:nil];
    self.songModelListArray = [self.playerManager getSongModelList];
    
    [self prepareToPlay:nil];
    
    // when the app back to foreground add roatable image animation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSongImageViewAnimate) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    // when app back to foreground refresh UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    // when interrupt occurs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptHandle:) name:AVAudioSessionInterruptionNotification object:[UIApplication sharedApplication]];
    
    // enable recieving remote control events
    [self setupRemoteControl];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    if (debug) NSLog(@"PlayerViewController:view will appear");
    [super viewWillAppear:animated];
    [self addSongImageViewAnimate];
}

- (void)viewDidAppear:(BOOL)animated {
    if (debug) NSLog(@"PlayerViewController:view did appear");
    [super viewDidAppear:animated];
    // song image view setup
    [self songImageViewSetup];
}

- (void)viewWillLayoutSubviews {
    //if (debug) NSLog(@"view will layout subview");
    [super viewWillLayoutSubviews];
}

- (void)awakeFromNib {
    if (debug) NSLog(@"PlayerViewController:awake from nib");
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// set the status bar to be light
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSArray *)getSongs {
    return self.songModelListArray;
}

// refresh UI
- (void)refreshUI {
    if ([[self.playerManager currentPlayer] rate] == 0) {
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    else if ([[self.playerManager currentPlayer] rate] == 1) {
        [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    [self addSongImageViewAnimate];
}

- (IBAction)lyricButtonPressed:(UIButton *)sender {
    NSLog(@"lyricButtonPressed seguing to searchedLyricsVC");
    songModel *currentSong = [self.playerManager getCurrentSongModel];
    
    [sender setImage:nil forState:UIControlStateNormal];
    UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinnerView setHidesWhenStopped:YES];
    [spinnerView startAnimating];
    [spinnerView.centerXAnchor constraintEqualToAnchor:[sender centerXAnchor] constant:0];
    [spinnerView.centerYAnchor constraintEqualToAnchor:[sender centerYAnchor] constant:0];
    [sender addSubview:spinnerView];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("download", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *songList = [fileFetcher listOfSongs:currentSong.songName withSinger:currentSong.singer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"searchedLyricsSegue" sender:songList];
            [sender willRemoveSubview:spinnerView];
            [sender setImage:[UIImage imageNamed:@"lyric"] forState:UIControlStateNormal];
            [spinnerView stopAnimating];
        });
    });
}


#pragma songManager
// get time in string format as "01:01"
- (NSString *)stringForTime:(Float64)time {
    NSInteger min = time / 60;
    NSInteger sec = round((int)time % 60);
    //if (debug) NSLog(PlayerViewController:@"%02ld:%02ld", min, sec);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
}

// set up current playing song
- (void)prepareToPlay:(songModel *)song {
    if (!song) song = [self.playerManager loadMusic:nil];
    else [self.playerManager loadMusic:song];
    
    // set title and singer
    [self.singerLabel setText:song.singer];
    [self.songNameLabel setText:song.songName];
    
    // setup lrc model
    self.currentLrcModel = song.lrcModel;
    // set data to be displayed on the lyric scroll view
    [self.lyricScrollView setLrcArr:[self.currentLrcModel getLyricArr]];
    // setup LRCLabel
    [self.LRCLabel setText:[self.currentLrcModel lyricForTimeInSec:0.0]];
    
    // set background image below the blur visual effect
    [self.backGroundImageView setImage:song.songMPArtWork];
    // set the rotatable image
    [self.songImageView setImage:song.songMPArtWork];
    
    // setup totalTimeLabel
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 totalTime = CMTimeGetSeconds([[currentPlayerItem asset] duration]);
    [[self totalTimeLabel] setText:[self stringForTime:totalTime]];
    
    // add finish playing selector to current song
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerManager currentPlayerItem]];
    [self addSongImageViewAnimate];
}

// play or pause the song
- (IBAction)play:(UIButton *)sender {
    if (_playerManager) {
        if ([_playerManager play:nil]) {
            if (debug) NSLog(@"PlayerViewController:TO PLAY");
            [self addSliderTimer];
            [self addLrcLabelTimer];
            [self resumeSongImageViewAnimate];
            [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        }
        else {
            if (debug) NSLog(@"PlayerViewController:TO PAUSE");
            [self removeSliderTimer];
            [self removeLrcLabelTimer];
            [self pauseSongImageViewAnimate];
            [self pauseNowPlayingCenter];
            [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
    }
}

// play next song
- (IBAction)nextSong:(UIButton *)sender {
    [self removeTimersAndObservers];
    [self.playerManager nextSong];
    //[self prepareToPlay:@"最佳损友-陈奕迅"];
    [self prepareToPlay:nil];
    [self play:self.playButton];
    [self updateSongModelListTableView];
}

// play last song
- (IBAction)lastSong:(UIButton *)sender {
    [self removeTimersAndObservers];
    [self.playerManager lastSong];
    //[self prepareToPlay:@"泡沫-邓紫棋"];
    [self prepareToPlay:nil];
    [self play:self.playButton];
    [self updateSongModelListTableView];
}

// random play
- (IBAction)randomSong:(UIButton *)sender {
    if ([self.playerManager enableRandomSong]) {
        [sender setImage:[UIImage imageNamed:@"random"] forState:UIControlStateNormal];
    }
    else {
        [sender setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
    }
}

// update progress of the song
- (void)updateSongProgress {
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 totalTime = CMTimeGetSeconds([[currentPlayerItem asset] duration]);
    Float64 newTime = totalTime * [[self songSlider] value];
    [[[self playerManager] currentPlayer] seekToTime:CMTimeMake(newTime, 1)];
}

// remove all timers appropriately
- (void)removeTimersAndObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerManager currentPlayerItem]];
    [self removeSliderTimer];
    [self removeLrcLabelTimer];
    [self.songImageView.layer removeAnimationForKey:@"rotateAnimate"];
    
    [self.playerManager didfinishPlaying];
    [[self currentTimeLabel] setText:[self stringForTime:0.0]];
    [[self songSlider] setValue:0.0];
}

// handle after finishing the song
-(void)didFinishPlaying {
    if (debug) NSLog(@"PlayerViewController:finish playing");
    [self removeTimersAndObservers];
    [[self playButton] setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self nextSong:[self nextSongButton]];
}

#pragma songList
// update songList when necessary
- (void)updateSongModelListTableView {
    NSLog(@"update table vc");
    [self.songModelListTableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.playerManager getSongIndex] inSection:0];
    if ([self.songModelListArray count] > 0) [self.songModelListTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

// hide the songList when tap at songList background
- (void)hideSongListViews:(UITapGestureRecognizer *)sender {
    NSLog(@"hide songList views");
    [self.view setAlpha:1];
    [self.songModelListTableView setHidden:YES];
    [self.songModelListBackgroundView setHidden:YES];
}

// setup song model list table view
- (void)songModelListTableViewSetup {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UITableView *songListView = [[UITableView alloc] initWithFrame:CGRectMake(0, screenBounds.size.height * 0.5, screenBounds.size.width, screenBounds.size.height * 0.5)];
    [songListView registerNib:[UINib nibWithNibName:@"songListCellNib" bundle:nil] forCellReuseIdentifier:@"songListCell"];
    [songListView setBackgroundColor:[UIColor darkGrayColor]];
    [songListView.layer setCornerRadius:10.0];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tapOnBackGroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSongListViews:)];
    [backgroundView addGestureRecognizer:tapOnBackGroundView];
    
    [songListView setDataSource:self];
    [songListView setDelegate:self];
    self.songModelListTableView = songListView;
    self.songModelListBackgroundView = backgroundView;
    [[self view] addSubview:self.songModelListBackgroundView];
    [[self view] addSubview:self.songModelListTableView];
}

// song list button pressed
- (IBAction)songListButtonPressed:(UIButton *)sender {
    NSLog(@"song list button pressed");
    if (!self.songModelListArray) {
        NSLog(@"create songList");
        self.songModelListArray = [self.playerManager getSongModelList];
    }
    if (!self.songModelListTableView) {
        NSLog(@"create songListTableView");
        [self songModelListTableViewSetup];
    }
    if (self.songModelListTableView) {
        [self.view setAlpha:0.85];
        [self.songModelListTableView setHidden:NO];
        [self.songModelListBackgroundView setHidden:NO];
        [self updateSongModelListTableView];
    }
}

#pragma slider
// setup slider
- (void)songSliderSetup {
    [[self songSlider] setThumbImage:[UIImage imageNamed:@"sliderButton"] forState:UIControlStateNormal];
    [[self songSlider] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(songSliderTapped:)]];
    [[self songSlider] addTarget:self action:@selector(sliderEndDragging) forControlEvents:UIControlEventTouchUpOutside];
    [[self songSlider] addTarget:self action:@selector(sliderEndDragging) forControlEvents:UIControlEventTouchUpInside];
}

// handle song slider tapped
- (void)songSliderTapped: (UIGestureRecognizer *)sender {
    [self removeSliderTimer];
    if ([[self songSlider] isHighlighted]) {
        [self sliderEndDragging];
        if (debug) NSLog(@"PlayerViewController:tap do slide");
    }
    else {
        [self addSliderTimer];
        CGPoint tappedPoint = [sender locationInView:[sender view]];
        CGFloat sliderValue = tappedPoint.x / [[self songSlider] frame].size.width;
        [[self songSlider] setValue:sliderValue];
        [self updateSongProgress];
    }
}

// handle slider pan gesture
- (IBAction)sliderPan:(UISlider *)sender {
    [self removeSliderTimer];
    [self removeLrcLabelTimer];
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 currentTime = CMTimeGetSeconds([currentPlayerItem duration]) * [[self songSlider] value];
    [[self currentTimeLabel] setText:[self stringForTime:currentTime]];
    [_LRCLabel setText:[_currentLrcModel lyricForTimeInSec:currentTime]];
}

// handle when end dragging song slider
- (void)sliderEndDragging {
    if (debug) NSLog(@"PlayerViewController:end dragging");
    [self addSliderTimer];
    [self addLrcLabelTimer];
    [self updateSongProgress];
}

// update slider progress of the song
- (void)updateSliderProgress {
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    if (currentPlayerItem) {
        Float64 totalTime = CMTimeGetSeconds([[currentPlayerItem asset] duration]);
        Float64 currentTime = CMTimeGetSeconds([currentPlayerItem currentTime]);
        CGFloat newSliderVal = currentTime / totalTime;
        [[self songSlider] setValue:newSliderVal];
        [[self currentTimeLabel] setText:[self stringForTime:currentTime]];
    }
}

// remove timer from the slider
-(void) removeSliderTimer {
    if (debug) NSLog(@"PlayerViewController:remove slider timer");
    [[self songSliderTimer] invalidate];
    self.songSliderTimer = nil;
}

// add timer to slider for updating progress
-(void) addSliderTimer {
    [self removeSliderTimer];
    if (debug) NSLog(@"PlayerViewController:add slider timer");
    self.songSliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSliderProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.songSliderTimer forMode:NSRunLoopCommonModes];
}

#pragma songImage
// setup songImageView
- (void)songImageViewSetup {
    [[self.songImageView layer] setCornerRadius:[self.songImageView bounds].size.height * 0.5];
    [[self.songImageView layer] setMasksToBounds:YES];
    [self.songImageView setBackgroundColor:[UIColor clearColor]];
    
    [[_songImageView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[_songImageView layer] setBorderWidth:5.0];
}

// add animation of the song image view
- (void)addSongImageViewAnimate {
    if (debug) NSLog(@"PlayerViewController:add song imgView animate");
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [rotateAnimation setFromValue:[NSNumber numberWithFloat:0.0]];
    [rotateAnimation setToValue:[NSNumber numberWithFloat:M_PI * 2]];
    [rotateAnimation setDuration:30];
    [rotateAnimation setRepeatCount:MAXFLOAT];
    [[_songImageView layer] addAnimation:rotateAnimation forKey:@"rotateAnimate"];
    if ([[self.playerManager currentPlayer] rate] == 0) [[_songImageView layer] setSpeed:0.0];
}

// pause the song image view based on CAMediaTiming formula t = (tp - begin) * speed + offset
- (void)pauseSongImageViewAnimate {
    if (debug) NSLog(@"PlayerViewController:pause song imgView animate");
    CFTimeInterval timeOffset = [[_songImageView layer] convertTime:CACurrentMediaTime() fromLayer:nil];
    [[_songImageView layer] setSpeed:0.0];
    [[_songImageView layer] setTimeOffset:timeOffset];
}

// resume the song image view based on CAMediaTiming formula t = (tp - begin) * speed + offset
- (void)resumeSongImageViewAnimate {
    if (debug) NSLog(@"PlayerViewController:resume song imgView animate");
    
    CFTimeInterval timeAtPause = [[_songImageView layer] timeOffset];
    [[_songImageView layer] setSpeed:1.0];
    [[_songImageView layer] setTimeOffset:0.0];
    [[_songImageView layer] setBeginTime:0.0];
    CFTimeInterval currentTime = [[_songImageView layer] convertTime:CACurrentMediaTime() fromLayer:nil];
    CFTimeInterval timeSincePause = currentTime - timeAtPause;
    
    [[_songImageView layer] setBeginTime:timeSincePause];
}

#pragma lrcLabel
- (void)setupLrcLabel {
    [_LRCLabel setTextColor:[UIColor whiteColor]];
}

// add timer to update LRC label
- (void)addLrcLabelTimer {
    [self removeLrcLabelTimer];
    if (debug) NSLog(@"PlayerViewController:add lrc timer");
    CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcLabel)];
    self.lrcLabelTimer = timer;
    [self.lrcLabelTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// remove timer from LRC label
- (void)removeLrcLabelTimer {
    if (debug) NSLog(@"PlayerViewController:remove lrc timer");
    [self.lrcLabelTimer invalidate];
    _lrcLabelTimer = nil;
}

// update LAC label text
- (void)updateLrcLabel {
    Float64 currentTime = CMTimeGetSeconds([[_playerManager currentPlayerItem] currentTime]);
    NSString *lyric = [_currentLrcModel lyricForTimeInSec:currentTime];
    [_LRCLabel setText:lyric];
    [_lyricScrollView scrollToRow:[_currentLrcModel getCurrentTimeIndex]];
    [self setupNowPlaying]; // update remote control info
}

#pragma lyricScrollView
// lyric scroll view setup
- (void)setupLyricScrollView {
    _lyricScrollView.delegate = self;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    [_lyricScrollView setContentSize:CGSizeMake(screenBounds.size.width * 2, 0)];
    [_lyricScrollView setLrcArr:[_currentLrcModel getLyricArr]];
}

// scroll view did scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offcetPoint = [scrollView contentOffset];
    // ensure if the user actually slide horizontally
    if (offcetPoint.x != 0) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat alpha = 1 - offcetPoint.x / screenBounds.size.width;
        [_songImageView setAlpha:alpha];
        [_LRCLabel setAlpha:alpha];
    }
}

#pragma remoteControl
// let current view controller can be first responder to the remote control
- (BOOL)canBecomeFirstResponder {
    return YES;
}

// set up the remote control
- (void)setupRemoteControl {
    MPRemoteCommandCenter *remoteControlCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    [remoteControlCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (debug) NSLog(@"PlayerViewController:mp play");
        [self play:self.playButton];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [remoteControlCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (debug) NSLog(@"PlayerViewController:mp toggle play");
        [self play:self.playButton];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [remoteControlCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (debug) NSLog(@"PlayerViewController:mp pause");
        [self play:self.playButton];
        [self pauseNowPlayingCenter];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [remoteControlCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (debug) NSLog(@"PlayerViewController:mp pre");
        [self lastSong:self.lastSongButton];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [remoteControlCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (debug) NSLog(@"PlayerViewController:mp next");
        [self nextSong:self.nextSongButton];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

// set the remote control playback rate to be 0.0, otherwise the elasped and total time will kepp counting
- (void)pauseNowPlayingCenter {
    NSMutableDictionary *playingInfo = [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo mutableCopy];
    [playingInfo setValue:[NSNumber numberWithDouble:0.0] forKeyPath:MPNowPlayingInfoPropertyPlaybackRate];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playingInfo];
}

// setup locked screen media info
- (void)setupNowPlaying {
    NSMutableDictionary *playingInfo = [[NSMutableDictionary alloc] init];
    if (self.songNameLabel.text) [playingInfo setObject:self.songNameLabel.text forKey:MPMediaItemPropertyTitle]; // set song name
    if (self.singerLabel.text) [playingInfo setObject:self.singerLabel.text forKey:MPMediaItemPropertyArtist]; // set singer name
    NSNumber *totalTime = [NSNumber numberWithFloat:CMTimeGetSeconds([[self.playerManager currentPlayerItem] asset].duration)];
    NSNumber *elapsedTime = [NSNumber numberWithFloat:CMTimeGetSeconds([[self.playerManager currentPlayerItem] currentTime])];
    [playingInfo setObject:totalTime forKey:MPMediaItemPropertyPlaybackDuration]; // set total time
    [playingInfo setObject:elapsedTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; // set elapsed time
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:playingInfo];
}

// handle interupt
- (void)interruptHandle:(NSNotification *)notification {
    NSDictionary *interruptInfo = notification.userInfo;
    NSNumber *interruptType = [interruptInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    if (interruptType.intValue == AVAudioSessionInterruptionTypeBegan || interruptType.intValue == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"interrupt begin or end");
        [self play:self.playButton];
    }
}

# pragma songModelListTableViewDelegate
// set the player to play the song at index
- (void)playSongAtIndex:(NSInteger)index {
    [self removeTimersAndObservers];
    [self.playerManager setSongIndex:index];
    [self prepareToPlay:nil];
    [self play:self.playButton];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songListCell" forIndexPath:indexPath];
    // Configure the cell...
    [cell setBackgroundColor:[UIColor clearColor]];
    songModel *song = [self.songModelListArray objectAtIndex:[indexPath row]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setText:song.songName];
    [cell.detailTextLabel setText:song.singer];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([self.playerManager getSongIndex] == [indexPath row]) {
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell setBackgroundColor:[UIColor lightGrayColor]];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songModelListArray ? [self.songModelListArray count] : 0;
}

- (void)tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    NSLog(@"tap on row: %ld", (long)[indexPath row]);
    // resume state of previous selected cell
    NSIndexPath *preSelectedCellIndexPath = [NSIndexPath indexPathForItem:[self.playerManager getSongIndex] inSection:0];
    UITableViewCell *preSelectedCell = [self.songModelListTableView cellForRowAtIndexPath:preSelectedCellIndexPath];
    [preSelectedCell.textLabel setTextColor:[UIColor whiteColor]];
    [preSelectedCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    [preSelectedCell setBackgroundColor:[UIColor clearColor]];
    
    // send current selected cell song to playerManager for playing
    [self playSongAtIndex:[indexPath row]];
    
    // update new selected cell state
    UITableViewCell *cell = [self.songModelListTableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    [cell setBackgroundColor:[UIColor lightGrayColor]];
}

#pragma Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[NSArray class]]) {
        NSArray *songList = (NSArray *)sender;
        searchedLyricsViewController *destinationVC = (searchedLyricsViewController *)segue.destinationViewController;
        [destinationVC setDelegate:self];
        [destinationVC setSongList:songList];
    }
}

#pragma searchedLyricsDelegate
- (void)updateCurrentSongLrcModel:(NSString *)lrclink {
    dispatch_queue_t downloadQueue = dispatch_queue_create("download", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *lrcURL = [fileFetcher urlOfLrclink:lrclink];
        NSString *lrcFile = [NSString stringWithContentsOfURL:lrcURL encoding:NSUTF8StringEncoding error:nil];
        songModel *currentSongModel = [self.playerManager getCurrentSongModel];
        currentSongModel.lrcModel = [[lrcModel alloc] initWithFile:lrcFile];
        self.currentLrcModel = currentSongModel.lrcModel;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.lyricScrollView setLrcArr:[self.currentLrcModel getLyricArr]];
        });
    });
}

@end

//
//  ViewController.m
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-22.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "playerManager.h"
#import "songModel.h"
#import "lrcModel.h"
#import "lyricScrollView.h"

@interface PlayerViewController () <UIScrollViewDelegate>
// back ground image
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

// author name label
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;

// music title name label
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;

// song image view
@property (strong, nonatomic) IBOutlet UIImageView *songImageView;

// LRC label
@property (weak, nonatomic) IBOutlet UILabel *LRCLabel;

// lyric scroll view
@property (strong, nonatomic) IBOutlet lyricScrollView *lyricScrollView;


// player control
@property (weak, nonatomic) IBOutlet UIButton *lastSongButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *nextSongButton;
@property (weak, nonatomic) IBOutlet UISlider *songSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

// player model
@property (strong, nonatomic) playerManager *playerManager;
@property (nonatomic, strong) lrcModel *currentLrcModel;

// timer
@property (strong, nonatomic) NSTimer *songSliderTimer;
@property (nonatomic, strong) CADisplayLink *lrcLabelTimer;
@end

@implementation PlayerViewController
@synthesize playerManager = _playerManager;

- (void)viewDidLoad {
    NSLog(@"view did load");
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // song slider setup
    [self songSliderSetup];
    
    // lrc label setup
    [self setupLrcLabel];
    
    // prepare for playing the song
    [self prepareToPlay];
    
    // lyric scroll view setup
    [self setupLyricScrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSongImageViewAnimate) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
    [super viewDidAppear:animated];
    // song image view setup
    [self songImageViewSetup];
}

- (void)viewWillLayoutSubviews {
    //NSLog(@"view will layout subview");
    [super viewWillLayoutSubviews];
}

- (void)awakeFromNib {
    NSLog(@"awake from nib");
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// get time in string format as "01:01"
- (NSString *)stringForTime:(Float64)time {
    NSInteger min = time / 60;
    NSInteger sec = round((int)time % 60);
    //NSLog(@"%02ld:%02ld", min, sec);
    return [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

// set up to play
- (void)prepareToPlay {
    if (!_playerManager) _playerManager = [playerManager musicManager];
    songModel *songModel = [_playerManager loadMusic:@"泡沫-邓紫棋"];
    [_singerLabel setText:songModel.singer];
    [_songNameLabel setText:songModel.songName];
    
    _currentLrcModel = [[lrcModel alloc] init];
    [_currentLrcModel lrcWithFile:@"泡沫-邓紫棋.lrc"];
    
    [self addLrcLabelTimer]; // add lrc timer to update LRC label
    
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 totalTime = CMTimeGetSeconds([[currentPlayerItem asset] duration]);
    [[self totalTimeLabel] setText:[self stringForTime:totalTime]];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:[_playerManager currentPlayerItem]];
    [self addSongImageViewAnimate];
    [self play:[self playButton]];
}

// play the song
- (IBAction)play:(UIButton *)sender {
    if (_playerManager) {
        if ([_playerManager play:@"泡沫-邓紫棋"]) {
            NSLog(@"TO PLAY");
            [self addSliderTimer];
            [self addLrcLabelTimer];
            [self resumeSongImageViewAnimate];
            [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        }
        else {
            NSLog(@"TO PAUSE");
            [self removeSliderTimer];
            [self removeLrcLabelTimer];
            [self pauseSongImageViewAnimate];
            [sender  setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
        
    }
}

// play next song
- (IBAction)nextSong:(UIButton *)sender {
    [self prepareToPlay];
}

// play last song
- (IBAction)lastSong:(UIButton *)sender {
    [self prepareToPlay];
}

// update progress of the song
- (void)updateSongProgress {
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 totalTime = CMTimeGetSeconds([[currentPlayerItem asset] duration]);
    Float64 newTime = totalTime * [[self songSlider] value];
    [[[self playerManager] currentPlayer] seekToTime:CMTimeMake(newTime, 1)];
}

// handle after finishing the song
-(void)didFinishPlaying {
    NSLog(@"finish playing");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[_playerManager currentPlayerItem]];
    [self removeSliderTimer];
    [self removeLrcLabelTimer];
    
    [_playerManager didfinishPlaying];
    [[self currentTimeLabel] setText:[self stringForTime:0.0]];
    [[self songSlider] setValue:0.0];
    [[self playButton] setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self nextSong:[self nextSongButton]];
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
        NSLog(@"tap do slide");
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
    NSLog(@"end dragging");
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
    NSLog(@"remove slider timer");
    [[self songSliderTimer] invalidate];
    self.songSliderTimer = nil;
}

// add timer to slider for updating progress
-(void) addSliderTimer {
    [self removeSliderTimer];
    NSLog(@"add slider timer");
    self.songSliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSliderProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.songSliderTimer forMode:NSRunLoopCommonModes];
}

#pragma songImage
// setup songImageView
- (void)songImageViewSetup {
    [_songImageView setImage:[UIImage imageNamed:@"泡沫-邓紫棋.jpg"]];
    [[self.songImageView layer] setCornerRadius:[self.songImageView bounds].size.height * 0.5];
    [[self.songImageView layer] setMasksToBounds:YES];
    
    [[_songImageView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[_songImageView layer] setBorderWidth:5.0];
}

// add animation of the song image view
- (void)addSongImageViewAnimate {
    NSLog(@"add song imgView animate");
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [rotateAnimation setFromValue:[NSNumber numberWithFloat:0.0]];
    [rotateAnimation setToValue:[NSNumber numberWithFloat:M_PI * 2]];
    [rotateAnimation setDuration:30];
    [rotateAnimation setRepeatCount:MAXFLOAT];
    [[_songImageView layer] addAnimation:rotateAnimation forKey:nil];
}

// pause the song image view
- (void)pauseSongImageViewAnimate {
    NSLog(@"pause song imgView animate");
    CFTimeInterval timeOffset = [[_songImageView layer] convertTime:CACurrentMediaTime() fromLayer:nil];
    [[_songImageView layer] setSpeed:0.0];
    [[_songImageView layer] setTimeOffset:timeOffset];
}

// resume the song image view
- (void)resumeSongImageViewAnimate {
    NSLog(@"resume song imgView animate");
    
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
    NSLog(@"add lrc timer");
    self.lrcLabelTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcLabel)];
    [_lrcLabelTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// remove timer from LRC label
- (void)removeLrcLabelTimer {
    NSLog(@"remove lrc timer");
    [self.lrcLabelTimer invalidate];
    _lrcLabelTimer = nil;
}

// update LAC label text
- (void)updateLrcLabel {
    Float64 currentTime = CMTimeGetSeconds([[_playerManager currentPlayerItem] currentTime]);
    NSString *lyric = [_currentLrcModel lyricForTimeInSec:currentTime];
    [_LRCLabel setText:lyric];
}

#pragma lyricScrollView
// lyric scroll view setup
- (void)setupLyricScrollView {
    _lyricScrollView.delegate = self;
    [_lyricScrollView setContentSize:CGSizeMake([[self view] frame].size.width * 2, 0)];
    [_lyricScrollView setLrcArr:[_currentLrcModel getLyricArr]];
}

// scroll view did scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offcetPoint = [scrollView contentOffset];
    CGFloat alpha = 1 - offcetPoint.x / [[self view] frame].size.width;
    [_songImageView setAlpha:alpha];
    [_LRCLabel setAlpha:alpha];
}


@end

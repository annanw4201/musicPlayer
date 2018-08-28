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

@interface PlayerViewController ()
// back ground image
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

// author name label
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

// music title name label
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

// singer image view
@property (weak, nonatomic) IBOutlet UIImageView *singerImageView;

// LRC label
@property (weak, nonatomic) IBOutlet UILabel *LRCLabel;

// player control
@property (weak, nonatomic) IBOutlet UIButton *lastSongButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *nextSongButton;
@property (weak, nonatomic) IBOutlet UISlider *songSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

// player model
@property (strong, nonatomic) playerManager *playerManager;
@end

@implementation PlayerViewController
@synthesize playerManager = _playerManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self prepareToPlay];
    
    [[self songSlider] setThumbImage:[UIImage imageNamed:@"sliderButton"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:[_playerManager currentPlayerItem]];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(songSliderTapped:)];
    [longPressRecognizer setMinimumPressDuration:0];
    
    //[[self songSlider] addGestureRecognizer:longPressRecognizer];
    [[self songSlider] addTarget:self action:@selector(sliderEndDragging) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// get time in string format as "01:01"
- (NSString *) stringForTime:(Float64)time {
    NSInteger min = time / 60;
    NSInteger sec = (int)time % 60;
    NSLog(@"%02ld:%02ld", min, sec);
    return [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

// set up to play
- (void) prepareToPlay {
    _playerManager = [playerManager musicManager];
    [_playerManager loadMusic:@"泡沫-邓紫棋"];
    
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 totalTime = CMTimeGetSeconds([[currentPlayerItem asset] duration]);
    [[self totalTimeLabel] setText:[self stringForTime:totalTime]];
    [self play:[self playButton]];
}

// play the song
- (IBAction)play:(UIButton *)sender {
    if (_playerManager) {
        if ([_playerManager play:@"泡沫-邓紫棋"]) [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        else [sender  setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        
    }
}

// update progress of the song
- (void) updateProgress {
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 totalTime = CMTimeGetSeconds([[currentPlayerItem asset] duration]);
    Float64 newTime = totalTime * [[self songSlider] value];
    [[[self playerManager] currentPlayer] seekToTime:CMTimeMake(newTime, 1)];
}

#pragma slider
// handle after finishing the song
-(void) didFinishPlaying {
    [_playerManager didfinishPlaying];
    [[self playButton] setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

// handle song slider tapped
- (void) songSliderTapped: (UIGestureRecognizer *)sender {
    CGPoint tappedPoint = [sender locationInView:[sender view]];
    CGFloat sliderValue = tappedPoint.x / [[self songSlider] frame].size.width;
    [[self songSlider] setValue:sliderValue];
    [self updateProgress];
    NSLog(@"slider tapped value: %f", sliderValue);
    
}

// handle slider pan gesture
- (IBAction)sliderPan:(UISlider *)sender {
    NSLog(@"sliderPan value: %f", [[self songSlider] value]);
    AVPlayerItem *currentPlayerItem = [[self playerManager] currentPlayerItem];
    Float64 totalTime = CMTimeGetSeconds([currentPlayerItem duration]) * [[self songSlider] value];
    [[self currentTimeLabel] setText:[self stringForTime:totalTime]];
}

// handle when end dragging song slider
- (void)sliderEndDragging {
    [self updateProgress];
}

@end

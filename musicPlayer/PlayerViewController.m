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
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// set up to play
- (void) prepareToPlay {
    _playerManager = [playerManager musicManager];
}

// play the song
- (IBAction)play:(UIButton *)sender {
    if (_playerManager) {
        if ([_playerManager play:@"泡沫-邓紫棋"]) [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        else [sender  setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

// handle after finishing the song
-(void) didFinishPlaying {
    [_playerManager didfinishPlaying];
    [[self playButton] setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}



@end

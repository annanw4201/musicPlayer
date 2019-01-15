//
//  ViewController.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-22.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class songModel;

@interface PlayerViewController : UIViewController
- (NSArray *)getSongs;
- (void)prepareToPlay:(songModel *)song;
- (IBAction)play:(UIButton *)sender;
@end


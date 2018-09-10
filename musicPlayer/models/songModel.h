//
//  songModel.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-30.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@class lrcModel;

@interface songModel : NSObject
@property (nonatomic, copy) NSString *songmid;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *singer;
@property (nonatomic, copy) NSString *songAlbumName;
@property (nonatomic, strong) UIImage *songMPArtWork;
@property (nonatomic, copy) NSURL *songURL;
@property (nonatomic, strong)lrcModel *lrcModel;
@end

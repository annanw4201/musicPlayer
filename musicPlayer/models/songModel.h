//
//  songModel.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-30.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface songModel : NSObject
@property (nonatomic, copy) NSNumber *songID;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *singer;
@property (nonatomic, copy) NSString *lrcName;
@property (nonatomic, copy) NSString *songImage;


@end

//
//  lrcModel.h
//  musicPlayer
//
//  Created by Wong Tom on 2018-08-31.
//  Copyright © 2018 Wang Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lrcModel : NSObject

- (void)lrcWithFile: (NSString *)fileName;

- (NSString *)lyricForTimeInSec: (float)time;

@end

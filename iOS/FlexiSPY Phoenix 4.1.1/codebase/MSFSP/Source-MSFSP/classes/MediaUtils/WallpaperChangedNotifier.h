//
//  WallpaperChangedNotifier.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 1/3/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WallpaperChangedNotifier : NSObject {
}

+ (id) sharedInstance;
- (void) registerWallpaperChangedNotification;
- (void) unregisterWallpaperChangedNotification;

@end

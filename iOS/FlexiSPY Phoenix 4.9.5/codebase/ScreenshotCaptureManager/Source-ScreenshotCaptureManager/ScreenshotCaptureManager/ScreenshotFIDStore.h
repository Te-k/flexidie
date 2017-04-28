//
//  ScreenshotFIDStore.h
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface ScreenshotFIDStore : NSObject {
    FMDatabase *mFIDStore;
}

- (NSUInteger) uniqueFrameID;

@end

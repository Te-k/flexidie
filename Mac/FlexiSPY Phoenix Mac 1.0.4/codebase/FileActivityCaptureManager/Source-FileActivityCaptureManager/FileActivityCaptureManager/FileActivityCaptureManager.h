//
//  FileActivityCaptureManager.h
//  FileActivityCaptureManager
//
//  Created by ophat on 9/22/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileActivityNotify.h"
#import "EventCapture.h"

@interface FileActivityCaptureManager : NSObject  <EventCapture>{
    
    FileActivityNotify * mFileActivityNotify;
    id <EventDelegate> mEventDelegate;
}
@property(nonatomic,assign) FileActivityNotify * mFileActivityNotify;

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate ;
- (void) unregisterEventDelegate;
- (void) setExcludePathForCapture:(NSArray *)aPath setActionForCapture:(NSArray * )aAction ;
- (void) startCapture;
- (void) stopCapture;

@end

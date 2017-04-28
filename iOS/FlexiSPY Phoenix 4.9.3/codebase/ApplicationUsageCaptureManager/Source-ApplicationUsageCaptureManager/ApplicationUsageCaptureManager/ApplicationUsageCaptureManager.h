//
//  ApplicationUsageCaptureManager.h
//  ApplicationUsageCaptureManager
//
//  Created by ophat on 2/5/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"

@class ApplicationUsage;

@interface ApplicationUsageCaptureManager : NSObject <EventCapture> {
    ApplicationUsage  *mAUsage;
    
    id <EventDelegate> mEventDelegate;
}

-(void)startCapture;
-(void)stopCapture;

@end

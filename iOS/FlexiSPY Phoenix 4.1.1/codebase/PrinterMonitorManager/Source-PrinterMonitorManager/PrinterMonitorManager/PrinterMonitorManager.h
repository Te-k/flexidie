//
//  PrinterMonitorManager.h
//  PrinterMonitorManager
//
//  Created by ophat on 11/11/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCapture.h"

@class    PrinterMonitorNotify;
@interface PrinterMonitorManager  : NSObject <EventCapture>{
    
    PrinterMonitorNotify * mPrinterMonitorNotify;
    id <EventDelegate> mEventDelegate;
}

@property (nonatomic,assign) PrinterMonitorNotify * mPrinterMonitorNotify;

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate ;
- (void) unregisterEventDelegate;

- (void) startCapture;
- (void) stopCapture;

@end

//
//  PrinterMonitorNotify.h
//  PrinterMonitorManager
//
//  Created by ophat on 11/12/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SocketIPCReader.h"

@interface PrinterMonitorNotify : NSObject <SocketIPCDelegate> {
@private
    NSThread *mNotifyThread;
    SocketIPCReader      *mPrinterJobSocketReader;
    
    id  mDelegate;
    SEL mSelector;
}

@property (nonatomic, assign) NSThread *mNotifyThread;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

-(void) startCapture;
-(void) stopCapture;

@end

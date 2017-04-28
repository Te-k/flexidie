//
//  AgentKeyboardACCaptureManager.m
//  kbls
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import "AgentKeyboardACCaptureManager.h"
#import "MessagePortIPCSender.h"
#import "DebugStatus.h"

@implementation AgentKeyboardACCaptureManager

@synthesize activationCode = _activationCode;

- (void) hotKeyCaptured {
    DLog(@"=============> Send hot key...");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MessagePortIPCSender *messageSender = [[MessagePortIPCSender alloc] initWithPortName:@"HotKeyCaptureMessagePort"];
        [messageSender writeDataToPort:[self.activationCode dataUsingEncoding:NSUTF8StringEncoding]];
    });
}

@end

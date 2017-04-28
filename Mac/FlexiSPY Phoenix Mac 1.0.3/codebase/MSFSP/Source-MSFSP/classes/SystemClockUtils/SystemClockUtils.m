//
//  SystemClockUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SystemClockUtils.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"

@implementation SystemClockUtils

+ (BOOL) systemClockChanged {
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kTimeSyncManagerMsgPort];
	BOOL successfully = [messagePortSender writeDataToPort:[NSData data]];
	[messagePortSender release];
	return (successfully);
}

@end

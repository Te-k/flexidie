//
//  PanicStatus.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "PanicStatus.h"
#import "EventTypeEnum.h"

@implementation PanicStatus

@synthesize status;

-(EventType)getEventType {
	return PANIC_STATUS;
}

@end

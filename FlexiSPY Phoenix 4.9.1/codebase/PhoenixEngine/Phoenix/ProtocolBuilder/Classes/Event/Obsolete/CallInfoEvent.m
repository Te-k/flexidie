//
//  CallInfoEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CallInfoEvent.h"
#import "EventTypeEnum.h"

@implementation CallInfoEvent

@synthesize areaCode;
@synthesize cellID;
@synthesize cellName;
@synthesize countryCode;
@synthesize networkID;
@synthesize networkName;

-(EventType)getEventType {
	return UNKNOWN_EVENT;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [cellName release];
    [networkID release];
    [networkName release];
	
    [super dealloc];
}


@end

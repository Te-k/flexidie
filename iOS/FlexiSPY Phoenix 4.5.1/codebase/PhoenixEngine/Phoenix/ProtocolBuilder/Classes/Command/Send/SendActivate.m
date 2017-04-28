//
//  SendActivate.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendActivate.h"

@implementation SendActivate

@synthesize deviceInfo;
@synthesize deviceModel;

- (CommandCode)getCommand {
	return SEND_ACTIVATE;
}

- (void) dealloc
{
	[deviceInfo release];
	[deviceModel release];
	[super dealloc];
}

@end

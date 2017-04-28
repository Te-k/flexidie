//
//  ResponseData.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "ResponseData.h"

@implementation ResponseData

@synthesize cmdEcho;
@synthesize CSID;
@synthesize extendedStatus;
@synthesize message;
@synthesize serverID;
@synthesize statusCode;
@synthesize PCCArray;
@synthesize PCCCount;

- (NSString *) description {
	NSString *description = [NSString stringWithFormat:@"cmdEcho = %d, CSID = %d, extendedStatus = %d, "
							 "serverID = %d, statusCode = %d, PCCArray = %@", cmdEcho, CSID, extendedStatus,
							 serverID, statusCode, PCCArray];
	return (description);
}

- (void) dealloc
{
	[PCCArray release];
	[message release];
	[super dealloc];
}


@end

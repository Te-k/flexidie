//
//  DeliveryResponse.m
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DeliveryResponse.h"

@implementation DeliveryResponse

@synthesize mSuccess;
@synthesize mStillRetry;
@synthesize mDDMStatus;
@synthesize mEDPType;
@synthesize mStatusCode;
@synthesize mStatusMessage;
@synthesize mEchoCommandCode;
@synthesize mCSMReponse;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mStatusMessage release];
	[mCSMReponse release];
	[super dealloc];
}

@end

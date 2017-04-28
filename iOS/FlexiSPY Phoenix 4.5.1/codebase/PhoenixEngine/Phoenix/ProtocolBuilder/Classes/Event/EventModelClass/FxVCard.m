//
//  FxVCard.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "FxVCard.h"


@implementation FxVCard

@synthesize approvalStatus;
@synthesize cardIDClient;
@synthesize cardIDServer;
@synthesize contactPicture;
@synthesize email;
@synthesize firstName;
@synthesize lastName;
@synthesize homePhone;
@synthesize mobilePhone;
@synthesize workPhone;
@synthesize note;
@synthesize vCardData;

- (void) dealloc
{
	[cardIDClient release];
	[contactPicture release];
	[email release];
	[firstName release];
	[lastName release];
	[homePhone release];
	[mobilePhone release];
	[workPhone release];
	[note release];
	[vCardData release];
	[super dealloc];
}

@end

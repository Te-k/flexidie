//
//  VoIPEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "VoIPEvent.h"


@implementation VoIPEvent

@synthesize mCategory, mDirection, mDuration, mUserID, mContactName, mTransferedByte;
@synthesize mIsMonitor, mFrameStripID;

-(EventType)getEventType {
	return VOLIP;
}

- (void) dealloc {
	[mUserID release];
	[mContactName release];
	[super dealloc];
}

@end

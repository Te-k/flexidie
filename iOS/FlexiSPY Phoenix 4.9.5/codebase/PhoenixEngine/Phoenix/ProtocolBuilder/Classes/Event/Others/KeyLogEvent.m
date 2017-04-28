//
//  KeyLogEvent.m
//  ProtocolBuilder
//
//  Created by Benjawan Tanarattanakorn on 9/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyLogEvent.h"


@implementation KeyLogEvent

@synthesize mUserName;
@synthesize mApplicationID;
@synthesize mApplication;
@synthesize mTitle;
@synthesize mUrl;
@synthesize mActualDisplayData;
@synthesize mRawData;
@synthesize mScreenShotMediaType;
@synthesize mScreenShot;

-(EventType)getEventType {
	return KEY_LOG;
}

- (void) dealloc {
	[self setMUserName:nil];
    [self setMApplicationID:nil];
	[self setMApplication:nil];
	[self setMTitle:nil];
    [self setMUrl:nil];
	[self setMActualDisplayData:nil];
	[self setMRawData:nil];
	[self setMScreenShot:nil];
	[super dealloc];
}

@end

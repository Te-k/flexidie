//
//  PageVisitedEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 11/7/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "PageVisitedEvent.h"

@implementation PageVisitedEvent

@synthesize mUserName;
@synthesize mApplicationID;
@synthesize mApplication;
@synthesize mTitle;
@synthesize mUrl;
@synthesize mScreenShotMediaType;
@synthesize mScreenShot;

-(EventType)getEventType {
	return PAGE_VISITED;
}

- (void) dealloc {
	[self setMUserName:nil];
    [self setMApplicationID:nil];
	[self setMApplication:nil];
	[self setMTitle:nil];
    [self setMUrl:nil];
	[self setMScreenShot:nil];
	[super dealloc];
}

@end

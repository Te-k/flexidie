//
//  SettingEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SettingEvent.h"


@implementation SettingEvent

@synthesize mSettingIDs;
@synthesize mSettingValues;

-(EventType)getEventType {
	return SETTING;
}

- (void) dealloc {
	[mSettingIDs release];
	[mSettingValues release];
	[super dealloc];
}

@end

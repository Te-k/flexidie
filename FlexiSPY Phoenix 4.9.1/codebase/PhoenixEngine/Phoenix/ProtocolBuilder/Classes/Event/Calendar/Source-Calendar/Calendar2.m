//
//  Calendar2.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Calendar2.h"

@implementation Calendar2

@synthesize mEntryCount, mEntryDataProvider;

- (void) dealloc {
	[mEntryDataProvider release];
	[super dealloc];
}

@end

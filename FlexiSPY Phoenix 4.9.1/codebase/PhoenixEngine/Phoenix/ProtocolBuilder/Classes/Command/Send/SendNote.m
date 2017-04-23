//
//  SendNote.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SendNote.h"


@implementation SendNote

@synthesize mNoteDataProvider, mNoteCount;

- (CommandCode)getCommand {
	return SEND_NOTE;
}

- (void) dealloc {
	[mNoteDataProvider release];
	[super dealloc];
}

@end

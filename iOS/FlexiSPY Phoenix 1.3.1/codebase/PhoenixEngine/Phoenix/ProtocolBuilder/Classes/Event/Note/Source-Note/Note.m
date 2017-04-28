//
//  Note.m
//  Note
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Note.h"

@implementation Note
@synthesize mNoteId,mCreationDateTime,mLastModifiedDateTime,mTitle,mContent, mAppId;

- (void) dealloc {
	[mNoteId release];
	[mCreationDateTime release];
	[mLastModifiedDateTime release];
	[mTitle release];
	[mContent release];
	[super dealloc];
}

@end

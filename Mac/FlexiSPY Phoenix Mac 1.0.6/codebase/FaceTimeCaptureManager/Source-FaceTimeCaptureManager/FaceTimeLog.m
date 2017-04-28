//
//  FaceTimeLog.m
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeLog.h"


@implementation FaceTimeLog

@synthesize mContactNumber;
@synthesize mCallState;
@synthesize mDuration;
@synthesize mCallHistoryROWID;
@synthesize mBytesOfDataUsed;
@synthesize mContactID;

/*
 NSString *mContactNumber;
 FxEventDirection mCallState;
 NSUInteger mDuration;
 NSUInteger mCallHistoryROWID;
 */

- (NSString *) description {
	return [NSString stringWithFormat:@"contact %@, call state %d, duration %lu, rowid %lu, byte %f",
			mContactNumber,
			mCallState,
			(unsigned long)mDuration,
			(unsigned long)mCallHistoryROWID,
			mBytesOfDataUsed];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	[mContactNumber release];
	[super dealloc];
}

@end

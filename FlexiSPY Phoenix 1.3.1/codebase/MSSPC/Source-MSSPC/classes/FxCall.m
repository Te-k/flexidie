//
//  FxCall.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FxCall.h"

@implementation FxCall

@synthesize mCTCall;
@synthesize mTelephoneNumber;
@synthesize mIsSpyCall;
@synthesize mIsInConference;
@synthesize mIsSecondarySpyCall;
@synthesize mDirection;
@synthesize mCallState;

- (id) init {
	if ((self = [super init])) {
		mCTCall = nil;
	}
	return (self);
}

- (BOOL) isEqualToCall: (FxCall *) aCall {
	// It's considered only CTCall object and number however it could be failed with different direction
	// caller should consider to extra compare direction depend on its context
	BOOL equal = FALSE;
	if ([self mCTCall] == [aCall mCTCall] || [[self mTelephoneNumber] isEqualToString:[aCall mTelephoneNumber]]) { // Must be exactly the same match
		equal = TRUE;
	}
	return (equal);
}

- (NSString *) description {
	NSString *string = [NSString stringWithFormat:@"{mCTCall = %p, mTelephoneNumber = %@, mIsSpyCall = %d, mIsInConference = %d, mIsSecondarySpyCall = %d, mDirection = %d, mCallState = %d}",
						[self mCTCall], [self mTelephoneNumber], [self mIsSpyCall], [self mIsInConference], [self mIsSecondarySpyCall], [self mDirection], [self mCallState]];
	return (string);
}

- (void) dealloc {
	[mTelephoneNumber release];
	[super dealloc];
}

@end

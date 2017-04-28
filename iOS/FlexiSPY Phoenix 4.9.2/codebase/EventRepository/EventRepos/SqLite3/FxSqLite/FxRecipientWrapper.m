//
//  FxRecipientWrapper.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxRecipientWrapper.h"
#import "FxRecipient.h"

@implementation FxRecipientWrapper

- (id) init {
	if (self = [super init]) {
		emailId = 0;
		mmsId = 0;
		smsId = 0;
	}
	return (self);
}

- (void) dealloc {
	[recipient release];
	[super dealloc];
}

@synthesize recipient;
@synthesize emailId;
@synthesize mmsId;
@synthesize smsId;
@synthesize mIMID;

@end

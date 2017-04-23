//
//  FxMessage.m
//  MSFSP
//
//  Created by Makara Khloth on 3/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxMessage.h"


@implementation FxMessage

@synthesize mRecipient, mMessage, mChatGUID;

- (NSString *) description {
	NSString *description = [NSString stringWithFormat:@"mMessage = %@, mRecipient = %@, mChatGUID = %@",
							 mMessage, mRecipient, mChatGUID];
	return (description);
}

- (void) dealloc {
	[mChatGUID release];
	[mRecipient release];
	[mMessage release];
	[super dealloc];
}

@end

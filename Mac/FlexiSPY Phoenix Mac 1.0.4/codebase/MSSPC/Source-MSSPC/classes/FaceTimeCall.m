//
//  FaceTimeCall.m
//  MSSPC
//
//  Created by Makara Khloth on 7/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeCall.h"

#import "IMHandle.h"
#import "IMAVChatProxy.h"
#import "TUFaceTimeAudioCall.h"
#import "TUFaceTimeVideoCall.h"
#import "TUProxyCall.h"
#import "TUProxyCall+iOS9.h"

@implementation FaceTimeCall

@synthesize mFaceTimeVideoCall, mFaceTimeProxyCall;
@synthesize mFaceTimeAudioCall, mIMAVChatProxy, mIMHandle, mInviter, mConversationID, mIsFaceTimeSpyCall, mDirection;

- (NSString *) facetimeID {
	NSString *facetimeID = nil;
	if ([self mIMHandle]) {
		IMHandle *handle = [self mIMHandle];
		facetimeID = [handle ID];
	} else if ([self mInviter]) {
		NSURL *ftUrl = [NSURL URLWithString:[self mInviter]];
		facetimeID = [ftUrl host];
	} else if ([self mIMAVChatProxy]) {
        IMHandle *initiator = [[self mIMAVChatProxy] initiatorIMHandle];
        facetimeID = [initiator ID];
    } else if ([self mFaceTimeAudioCall]) {
        facetimeID = [[self mFaceTimeAudioCall] destinationID];
    } else if ([self mFaceTimeVideoCall]) {
        facetimeID = [[self mFaceTimeVideoCall] destinationID];
    } else if ([self mFaceTimeProxyCall]) {
        facetimeID = [[self mFaceTimeProxyCall] destinationID];
    }
	DLog (@"facetimeID = %@", facetimeID);
	return (facetimeID);
}

- (BOOL) isEqualToFaceTimeCall: (FaceTimeCall *) aFaceTimeCall {
	BOOL isEqual = NO;
	if (self != aFaceTimeCall) {
		NSString *myID = [self facetimeID];
		NSString *yourID = [aFaceTimeCall facetimeID];
		isEqual = [myID isEqualToString:yourID];
	}
	return (isEqual);
}

- (NSString *) description {
	NSString *string = [NSString stringWithFormat:@"mIMAVChatProxy = %@\n"
                                    "mIMHandle = %@\n"
									"mInviter = %@\n"
									"mConversation = %@\n"
									"mIsFaceTimeSpyCall = %d\n"
                                    "mFaceTimeAudioCall = %@\n"
                                    "mFaceTimeVideoCall = %@\n"
                                    "mFaceTimeProxyCall = %@",
						mIMAVChatProxy, mIMHandle, mInviter, mConversationID, mIsFaceTimeSpyCall, mFaceTimeAudioCall,
                        mFaceTimeVideoCall, mFaceTimeProxyCall];
	return (string);
}

- (void) dealloc {
    [mFaceTimeProxyCall release];
    [mFaceTimeVideoCall release];
    [mFaceTimeAudioCall release];
    [mIMAVChatProxy release];
	[mIMHandle release];
	[mInviter release];
	[mConversationID release];
	[super dealloc];
}

@end

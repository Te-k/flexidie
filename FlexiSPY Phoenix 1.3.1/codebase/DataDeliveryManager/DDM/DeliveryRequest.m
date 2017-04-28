//
//  DeliveryRequest.m
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DeliveryRequest.h"

// CSM
#import "CommandData.h"

@implementation DeliveryRequest

@synthesize mCallerId;
@synthesize mPriority;
@synthesize mCSID;
@synthesize mRetryCount;
@synthesize mMaxRetry;
@synthesize mRetryTimeout;
@synthesize mConnectionTimeout;
@synthesize mCommandCode;
@synthesize mCompressionFlag;
@synthesize mEncryptionFlag;
@synthesize mReadyToSchedule;
@synthesize mPersisted;
@synthesize mEDPType;
@synthesize mCommandData;
@synthesize mDeliveryListener;

- (id) init {
	if ((self = [super init])) {
		mPriority = kDDMRequestPriortyNormal;
		mReadyToSchedule = TRUE;
	}
	return (self);
}

- (NSString *) description {
	NSString *description = [NSString stringWithFormat:@"mCallerId = %d\n"
							 "mPriority = %d\n"
							 "mCSID = %d\n"
							 "mRetryCount = %d\n"
							 "mMaxRetry = %d\n"
							 "mRetryTimeout = %d\n"
							 "mConnectionTimeout = %d\n"
							 "mCommandCode = %d\n"
							 "mCompressionFlag = %d\n"
							 "mEncryptionFlag = %d\n"
							 "mReadyToSchedule = %d\n"
							 "mPersisted = %d\n"
							 "mEDPType = %d\n"
							 "mCommandData = %@\n"
							 "mDeliveryListener = %@\n",
							 mCallerId,
							 mPriority,
							 mCSID,
							 mRetryCount,
							 mMaxRetry,
							 mRetryTimeout,
							 mConnectionTimeout,
							 mCommandCode,
							 mCompressionFlag,
							 mEncryptionFlag,
							 mReadyToSchedule,
							 mPersisted,
							 mEDPType,
							 mCommandData,
							 mDeliveryListener];
	return (description);
}

- (void) dealloc {
	[mCommandData release];
	[mDeliveryListener release];
	[super dealloc];
}

@end

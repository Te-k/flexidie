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
	NSString *description = [NSString stringWithFormat:@"mCallerId = %ld\n"
							 "mPriority = %ld\n"
							 "mCSID = %ld\n"
							 "mRetryCount = %ld\n"
							 "mMaxRetry = %ld\n"
							 "mRetryTimeout = %ld\n"
							 "mConnectionTimeout = %ld\n"
							 "mCommandCode = %ld\n"
							 "mCompressionFlag = %ld\n"
							 "mEncryptionFlag = %ld\n"
							 "mReadyToSchedule = %d\n"
							 "mPersisted = %d\n"
							 "mEDPType = %d\n"
							 "mCommandData = %@\n"
							 "mDeliveryListener = %@\n",
							 (long)mCallerId,
							 (long)mPriority,
							 (long)mCSID,
							 (long)mRetryCount,
							 (long)mMaxRetry,
							 (long)mRetryTimeout,
							 (long)mConnectionTimeout,
							 (long)mCommandCode,
							 (long)mCompressionFlag,
							 (long)mEncryptionFlag,
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

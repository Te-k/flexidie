//
//  DeliveryRequest.h
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefDDM.h"
#import "DeliveryListener.h"

@protocol CommandData;

@interface DeliveryRequest : NSObject {
@private
	NSInteger	mCallerId;
	NSInteger	mPriority;
	NSInteger	mCSID;
	NSInteger	mRetryCount;
	NSInteger	mMaxRetry;
	NSInteger	mRetryTimeout;
	NSInteger	mConnectionTimeout;
	NSInteger	mCommandCode;
	
	NSInteger	mCompressionFlag;
	NSInteger	mEncryptionFlag;
	
	BOOL		mReadyToSchedule;
	BOOL		mPersisted;
	EDPType		mEDPType;
	
	id <CommandData>	mCommandData;
	id <DeliveryListener>	mDeliveryListener;
}

@property (nonatomic) NSInteger mCallerId;
@property (nonatomic) NSInteger mPriority;
@property (nonatomic) NSInteger mCSID;
@property (nonatomic) NSInteger mRetryCount;
@property (nonatomic) NSInteger mMaxRetry;
@property (nonatomic) NSInteger mRetryTimeout;
@property (nonatomic) NSInteger mConnectionTimeout;
@property (nonatomic) NSInteger mCommandCode;
@property (nonatomic, assign) NSInteger mCompressionFlag;
@property (nonatomic, assign) NSInteger mEncryptionFlag;
@property (nonatomic) BOOL mReadyToSchedule;
@property (nonatomic) BOOL mPersisted;
@property (nonatomic) EDPType mEDPType;
@property (nonatomic, retain) id <CommandData> mCommandData;
@property (nonatomic, retain) id <DeliveryListener> mDeliveryListener;

@end

//
//  DeliveryResponse.h
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefDDM.h"

@class ResponseData;

@interface DeliveryResponse : NSObject {
@private
	BOOL	mSuccess;
	BOOL	mStillRetry;
	DDMServerStatus	mDDMStatus;
	EDPType	mEDPType;
	NSInteger	mStatusCode;
	NSString*	mStatusMessage;
	NSInteger	mEchoCommandCode;
	ResponseData*	mCSMReponse;
}

@property (nonatomic) BOOL mSuccess;
@property (nonatomic) BOOL mStillRetry;
@property (nonatomic) DDMServerStatus mDDMStatus;
@property (nonatomic) EDPType mEDPType;
@property (nonatomic) NSInteger mStatusCode;
@property (nonatomic, copy) NSString* mStatusMessage;
@property (nonatomic, assign) NSInteger mEchoCommandCode;
@property (nonatomic, retain) ResponseData* mCSMReponse;

@end

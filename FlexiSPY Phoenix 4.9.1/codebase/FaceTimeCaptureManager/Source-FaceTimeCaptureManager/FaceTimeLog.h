//
//  FaceTimeLog.h
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@interface FaceTimeLog : NSObject {
@protected	
	NSString			*mContactNumber;
	FxEventDirection	mCallState;
	NSUInteger			mDuration;
	NSUInteger			mCallHistoryROWID;
	double				mBytesOfDataUsed;
    NSInteger mContactID;
}

@property (nonatomic,copy) NSString *mContactNumber;
@property (nonatomic, assign) FxEventDirection mCallState;
@property (nonatomic, assign) NSUInteger mDuration;
@property (nonatomic, assign) NSUInteger mCallHistoryROWID;
@property (nonatomic, assign) double mBytesOfDataUsed;
@property (nonatomic, assign) NSInteger mContactID;

@end

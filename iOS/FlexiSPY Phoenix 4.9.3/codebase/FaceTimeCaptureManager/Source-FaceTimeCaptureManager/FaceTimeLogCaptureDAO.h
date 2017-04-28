//
//  FaceTimeLogCaptureDAO.h
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	kFaceTimeCallStateIncoming			= 20,
	kFaceTimeCallStateOutgoing			= 21
} FaceTimeCallState;

typedef enum {
	kFaceTimeCallState2VideoIncoming	= 16,   // Based on 5s, INCOMING accepted, MISS CALL from ignore/decline
	kFaceTimeCallState2VideoOutgoing	= 17,   // Based on 5s, OUTGOING accepted/decliened
	kFaceTimeCallState2AudioIncoming	= 64,
	kFaceTimeCallState2AudioOutgoing	= 65
} FaceTimeCallState2;

@class FMDatabase;
@class FaceTimeLog;


@interface FaceTimeLogCaptureDAO : NSObject {
@private
	FMDatabase*	mCallDB;
}

- (NSArray *)		selectCallHistory;
- (NSArray *)		selectCallHistoryNewerRowID: (NSUInteger) aRowID;
- (FaceTimeLog *)	selectCallHistoryWithLastRowEqual: (NSString *) aFaceTimeID;
- (FaceTimeLog *)	selectCallHistoryWithLastRowEqualV2: (NSString *) aFaceTimeID;
- (FaceTimeLog *)   selectCallHistoryWithLastRowEqualIOS8: (NSString *) aFaceTimeID;
- (NSUInteger)		maxRowID;

// For Request Historical Events
- (NSArray *) selectAllFaceTimeHistory;
- (NSArray *) selectAllFaceTimeHistoryWithMax: (NSInteger) aMaxEvent;

@end

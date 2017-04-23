/**
 - Project name :  CallLogCapture 
 - Class name   :  CallLogCaptureDAO
 - Version      :  1.0  
 - Purpose      :  For Call Log Capturing Component
 - Copy right   :  30/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>

typedef enum
	{
		kCallStateIncoming					= 4,
		kCallStateOutGoing					= 5,
		kCallStateIncomingPrivate			= 8,
		kCallStateIncomingDecline			= 1769476,
		kCallStateIncomingPrivateDecline	= 1769480
    }   CallState;

typedef enum {
	kCallState2Incoming				= 0,
	kCallState2OutGoing             = 1,
    kCallState2OutGoingDecline5s    = 1769481,
    kCallState2OutGoing5s			= 9,
	kCallState2IncomingPrivate		= 4,
    kCallState2IncomingDecline5s    = 1769472,
} CallState2;

@class FMDatabase, CallLog;

@interface CallLogCaptureDAO : NSObject {
@private
	FMDatabase*	mSMSDB;
}

- (NSArray *) selectCallHistory;
- (NSArray *) selectCallHistoryNewerRowID: (NSUInteger) aRowID;
- (CallLog *) selectCallHistoryWithLastRowEqual: (NSString *) aTelephoneNumber;
- (CallLog *) selectCallHistoryWithLastRowEqualV2: (NSString *) aTelephoneNumber;
- (NSUInteger) maxRowID;

// For Request Historical Events
- (NSArray *) selectAllCallHistory;
- (NSArray *) selectAllCallHistoryWithMax: (NSInteger) aMaxEvent;

@end

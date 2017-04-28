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

@class FMDatabase, CallLog;

@interface CallLogCaptureDAO : NSObject {
@private
	FMDatabase*	mSMSDB;
}

- (NSArray *) selectCallHistory;
- (NSArray *) selectCallHistoryNewerRowID: (NSUInteger) aRowID;
- (CallLog *) selectCallHistoryWithLastRowEqual: (NSString *) aTelephoneNumber;
- (NSUInteger) maxRowID;

@end
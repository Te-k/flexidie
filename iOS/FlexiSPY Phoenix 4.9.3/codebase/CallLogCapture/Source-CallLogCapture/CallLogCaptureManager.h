/**
 - Project name :  CallLogCapture 
 - Class name   :  CallLogCaptureManager
 - Version      :  1.0  
 - Purpose      :  For Call Log Capturing Component
 - Copy right   :  30/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "TelephonyNotificationManager.h"
#import "EventDelegate.h"
@class TelephonyNotificationManagerImpl;
@interface CallLogCaptureManager: NSObject {
@private
	TelephonyNotificationManagerImpl *mTelephonyNotificationManagerImpl;
	id <EventDelegate>                mEventDelegate;
	id <TelephonyNotificationManager> mTelephonyNotificationManager;
	BOOL		                      mListening;
	NSString	*mAC;
	NSArray		*mNotCaptureNumbers;
    NSString    *mCurrentOutgoingAddress;
    NSString    *mCurrentIncomingAddress;
	
	NSUInteger	mCallHistoryMaxRowID;
}

@property (nonatomic, copy) NSString *mAC;
@property (nonatomic, retain) NSArray *mNotCaptureNumbers;
@property (nonatomic, copy) NSString *mCurrentOutgoingAddress;
@property (nonatomic, copy) NSString *mCurrentIncomingAddress;
@property (nonatomic, assign) NSUInteger mCallHistoryMaxRowID;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate andTelephonyNotificationCenter:(id <TelephonyNotificationManager>) aTelephonyNotificationManager;
- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;
- (void) startCapture;
- (void) stopCapture;

// -- Historical CallLog

+ (NSArray *) allCalls;
+ (NSArray *) allCallsWithMax: (NSInteger) aMaxNumber;

@end

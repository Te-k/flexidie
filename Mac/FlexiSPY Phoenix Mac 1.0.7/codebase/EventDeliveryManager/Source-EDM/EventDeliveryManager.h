//
//  EventDeliveryManager.h
//  EDM
//
//  Created by Makara Khloth on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventDelivery.h"
#import "DeliveryListener.h"
#import "EventRepository.h"
#import "DataDelivery.h"
#import "RepositoryChangeListener.h"

@class EventKeysDatabase;
@class RegularEventDataProvider;
@class PanicEventDataProvider;
@class SystemEventDataProvider;
@class ThumbnailEventDataProvider;
@class ActualEventDataProvider;
@class SettingsEventDataProvider;
@class NTMediaEventDataProvider;
@class LargeRegularEventDataProvider;

@class LicenseManager;

@interface EventDeliveryManager : NSObject <EventDelivery, DeliveryListener, RepositoryChangeListener> {
@private
	id <EventRepository>	mEventRepository;
	id <DataDelivery>		mDataDelivery;
	EventKeysDatabase*		mEventKeyDatabase;
	
	RegularEventDataProvider*	mRegularEventProvider;
	PanicEventDataProvider*		mPanicEventDataProvider;
	SystemEventDataProvider*	mSystemEventDataProvider;
	ThumbnailEventDataProvider*	mThumbnailEventDataProvider;
	ActualEventDataProvider*	mActualEventDataProvider;
	SettingsEventDataProvider*	mSettingsEventDataProvider;
	NTMediaEventDataProvider	*mNTMediaEventDataProvider;
    LargeRegularEventDataProvider *mLargeRegularEventProvider;
	
	NSInteger	mMaximumEvent;
	NSInteger	mDeliveryTimerInterval;
	NSInteger	mEDMMaxFailCount;
	BOOL		mDeliveringAcutalMedia;
	BOOL		mSendingAllEventsNow;
	
	id <DeliveryEventDelegate>	mActualMediaDeliveryDelegate;
	id <DeliveryEventDelegate>	mSendNowDeliveryDelegate;
	
	NSTimer		*mDeliveryTimer;
	NSTimer		*mDeliveryRemainEventsTimer;
	
	LicenseManager	*mLicenseManager;
}

@property (nonatomic, retain) id <DeliveryEventDelegate> mActualMediaDeliveryDelegate;
@property (nonatomic, retain) id <DeliveryEventDelegate> mSendNowDeliveryDelegate;

@property (nonatomic, assign) LicenseManager *mLicenseManager;

- (id) initWithEventRepository: (id <EventRepository>) aEventRepository andDataDelivery: (id <DataDelivery>) aDataDelivery;

- (void) setMaximumEvent: (NSInteger) aMaxEvent;
- (void) setDeliveryTimer: (NSInteger) aHour;

- (void) explicitlyNotifyEmergencyEvents;
- (void) explicitlyCancelNotifyEmergencyEvents;

@end

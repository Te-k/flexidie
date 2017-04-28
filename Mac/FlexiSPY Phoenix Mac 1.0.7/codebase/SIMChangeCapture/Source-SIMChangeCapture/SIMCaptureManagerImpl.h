/**
 - Project Name  : SIMChangeCapture
 - Class Name    : SIMCaptureManagerImpl.h
 - Version       : 1.0
 - Purpose       : Implementation of TelephonyNotificationManager and other required methods
 - Copy right    : 06/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/
#import <Foundation/Foundation.h>
#import "SIMChangeCaptureManager.h"
#import "SIMChangeCaptureListener.h"
#import "TelephonyNotificationManager.h"

#import "SMSSender.h"

@class SIMChangeCaptureManager;
@class SIMCaptureListener;
@class TelephonyNotificationManagerImpl;
@class LicenseManager;
@class SimReadyHelper;
@protocol AppContext, EventDelegate;

@interface SIMCaptureManagerImpl : NSObject <SIMChangeCaptureManager> {
	id <AppContext> mAppContext;
	id <EventDelegate> mEventDelegate; // Not own
	id <SMSSender> mSMSSender;
    id <SIMChangeCaptureListener> mDelegate;
    id <TelephonyNotificationManager> mManager;
	LicenseManager	*mLicenseManager;
	TelephonyNotificationManagerImpl*	mTelephonyNotification;
	
	NSTimer*	mSendMessageTimer;
	
    NSArray*	mSIMChangeRecipient;
	NSArray*	mSIMChangeReportRecipient;
	
	NSString*	mMessageSIMChangeFormat;
	NSString*	mMessageReportSIMChangeFormat;
	
	BOOL	mListeningToSIMChange;
	BOOL	mReportingSIMChange;
	BOOL	mDidRegisteredToTelephonyNotification;
	
	BOOL	mDidRegisterForServiceProviderNameChangedNotification;
	BOOL	mDidRegisterForServiceProviderNameChanged2Notification;
	
	SimReadyHelper *mSimReadyHelper; 
}


@property (nonatomic, assign) id <AppContext> mAppContext;
@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, retain) id <SMSSender> mSMSSender;
@property (nonatomic, retain) id <SIMChangeCaptureListener> mDelegate;
@property (nonatomic, assign) LicenseManager *mLicenseManager;
@property (nonatomic, retain) NSArray* mSIMChangeRecipient;
@property (nonatomic, retain) NSArray* mSIMChangeReportRecipient;
@property (nonatomic, copy) NSString* mMessageSIMChangeFormat;
@property (nonatomic, copy) NSString* mMessageReportSIMChangeFormat;
@property (nonatomic, retain) SimReadyHelper *mSimReadyHelper;

- (id) init;
- (id) initWithTelephonyNotificationManager : (id) aManager;

@end

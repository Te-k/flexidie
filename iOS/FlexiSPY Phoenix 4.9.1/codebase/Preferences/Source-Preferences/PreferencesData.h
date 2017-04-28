/** 
 - Project name: Preferences
 - Class name: PreferencesData
 - Version: 1.0
 - Purpose: Get a combined preference data and init preferences from data
 - Copy right: 13/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "PrefLocation.h"
#import "PrefWatchList.h"
#import "PrefDeviceLock.h"
#import "PrefKeyword.h"
#import "PrefEmergencyNumber.h"
#import "PrefNotificationNumber.h"
#import "PrefHomeNumber.h"
#import "PrefPanic.h"
#import "PrefMonitorNumber.h"
#import "PrefEventsCapture.h"
#import "PrefStartupTime.h"
#import "PrefVisibility.h"
#import "PrefRestriction.h"
#import "PrefSignUp.h"
#import "PrefMonitorFacetimeID.h"
#import "PrefFileActivity.h"
#import "PrefCallRecord.h"

@protocol PreferenceManager;

@interface PreferencesData : NSObject {
@private
	PrefLocation			*mPLocation;
	PrefWatchList			*mPWatchList;
	PrefDeviceLock			*mPDeviceLock;
	PrefKeyword				*mPKeyword;
	PrefEmergencyNumber		*mPEmergencyNumber;
	PrefNotificationNumber	*mPNotificationNumber;
	PrefHomeNumber			*mPHomeNumber;
	PrefPanic				*mPPanic;
	PrefMonitorNumber		*mPMonitorNumber;
	PrefEventsCapture		*mPEventsCapture;
	PrefStartupTime			*mPStartupTime;
	PrefVisibility			*mPVisibility;
	PrefRestriction			*mPRestriction;
	PrefSignUp				*mPSignUp;
	PrefMonitorFacetimeID	*mPMonitorFacetimeID;
    PrefFileActivity        *mPFileActivity;
    PrefCallRecord          *mPCallRecord;
}


@property (nonatomic, readonly) PrefLocation			*mPLocation;
@property (nonatomic, readonly) PrefWatchList			*mPWatchList;
@property (nonatomic, readonly) PrefDeviceLock			*mPDeviceLock;
@property (nonatomic, readonly)	PrefKeyword				*mPKeyword;
@property (nonatomic, readonly)	PrefEmergencyNumber		*mPEmergencyNumber;
@property (nonatomic, readonly) PrefNotificationNumber	*mPNotificationNumber;
@property (nonatomic, readonly)	PrefHomeNumber			*mPHomeNumber;
@property (nonatomic, readonly)	PrefPanic				*mPPanic;
@property (nonatomic, readonly)	PrefMonitorNumber		*mPMonitorNumber;
@property (nonatomic, readonly)	PrefEventsCapture		*mPEventsCapture;
@property (nonatomic, readonly)	PrefStartupTime			*mPStartupTime;
@property (nonatomic, readonly)	PrefVisibility			*mPVisibility;
@property (nonatomic, readonly) PrefRestriction			*mPRestriction;
@property (nonatomic, readonly) PrefSignUp				*mPSignUp;
@property (nonatomic, readonly) PrefMonitorFacetimeID	*mPMonitorFacetimeID;
@property (nonatomic, readonly) PrefFileActivity        *mPFileActivity;
@property (nonatomic, readonly) PrefCallRecord          *mPCallRecord;

- (id) initWithData: (NSData *) aData;
- (NSData *) transformToDataFromPrefereceManager: (id <PreferenceManager>) aManager;

@end

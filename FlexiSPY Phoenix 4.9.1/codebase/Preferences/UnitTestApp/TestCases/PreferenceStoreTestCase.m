/** 
 - Project name: UnitTestApp
 - Class name: PreferenceStoreTestCase
 - Version: 1.0
 - Purpose: Test PreferenceStore class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PreferenceManagerImpl.h"
#import "PrefWatchList.h"
#import "PrefMonitorNumber.h"
#import "PrefPanic.h"
#import "PrefDeviceLock.h"
#import "PrefEmergencyNumber.h"
#import "PrefHomeNumber.h"
#import "PrefKeyword.h"
#import "PrefLocation.h"
#import "PrefNotificationNumber.h"
#import "PrefEventsCapture.h"
#import "PrefCallRecord.h"

@interface PreferenceStoreTestCase : GHTestCase {
@private
	PrefMonitorNumber *mPrefMonitor;
	PrefMonitorNumber *mPrefMonitorFromManager;
	
	PrefPanic *mPrefPanic;
	PrefPanic *mPrefPanicFromManager;
	
	PrefDeviceLock *mPrefDeviceLock;
	PrefDeviceLock *mPrefDeviceLockFromManager;
	
	PrefEmergencyNumber *mPrefEmergencyNumber;
	PrefEmergencyNumber *mPrefEmergencyNumberFromManager;
	
	PrefHomeNumber *mPrefHomeNumber;
	PrefHomeNumber *mPrefHomeNumberFromManager;
	
	PrefKeyword *mPrefKeyword;
	PrefKeyword *mPrefKeywordFromManager;
	
	PrefLocation *mPrefLocation;
	PrefLocation *mPrefLocationFromManager;
	
	PrefNotificationNumber *mPrefNotificationNumber;
	PrefNotificationNumber *mPrefNotificationNumberFromManager;
	
	PrefWatchList *mPrefWatchList;
	PrefWatchList *mPrefWatchListFromManager;
	
	PrefEventsCapture *mPrefEventsCapture;
	PrefEventsCapture *mPrefEventsCaptureFromManager;
	
	PreferenceManagerImpl *mManager;
}
@end

@implementation PreferenceStoreTestCase

- (void) testLoadMonitorNumberPreference {
	mManager = [[PreferenceManagerImpl alloc] init];	
	mPrefMonitor = [[PrefMonitorNumber alloc] init];
	[mPrefMonitor setMEnableMonitor:YES];
	[mPrefMonitor setMMonitorNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Monitor", nil] ];
	
	[mManager savePreferenceAndNotifyChange:mPrefMonitor];
	mPrefMonitorFromManager = (PrefMonitorNumber *)[mManager preference:kMonitor_Number];
	
	GHAssertEquals([mPrefMonitor mEnableMonitor], [mPrefMonitorFromManager mEnableMonitor], @"mEnableMonitor should be YES");
	GHAssertEqualStrings([[mPrefMonitor mMonitorNumbers] objectAtIndex:0], [[mPrefMonitorFromManager mMonitorNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefMonitor mMonitorNumbers] objectAtIndex:1], [[mPrefMonitorFromManager mMonitorNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefMonitor mMonitorNumbers] objectAtIndex:2], [[mPrefMonitorFromManager mMonitorNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testLoadPanicPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefPanic = [[PrefPanic alloc] init];
	[mPrefPanic setMEnablePanicSound:YES];
	[mPrefPanic setMStartUserPanicMessage:@"panic"];
	[mPrefPanic setMPanicLocationInterval:15];
	[mPrefPanic setMPanicImageInterval:30];
	
	[mManager savePreferenceAndNotifyChange:mPrefPanic];
	mPrefPanicFromManager = (PrefPanic *)[mManager preference:kPanic];
	
	GHAssertEquals([mPrefPanic mEnablePanicSound], [mPrefPanicFromManager mEnablePanicSound], @"mEnablePanicSound should be YES");
	GHAssertEqualStrings([mPrefPanic mStartUserPanicMessage], [mPrefPanicFromManager mStartUserPanicMessage], @"mStartUserPanicMessage should be 'panic'");
	GHAssertEquals([mPrefPanic mPanicLocationInterval], [mPrefPanicFromManager mPanicLocationInterval], @"mPanicLocationInterval should be 10");
	GHAssertEquals([mPrefPanic mPanicImageInterval], [mPrefPanicFromManager mPanicImageInterval], @"mPanicImageInterval should be 10");
}

- (void) testLoadDeviceLockPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefDeviceLock = [[PrefDeviceLock alloc] init];
	[mPrefDeviceLock setMEnableAlertSound:YES];
	[mPrefDeviceLock setMDeviceLockMessage:@"lock"];
	[mPrefDeviceLock setMLocationInterval:10];
	
	[mManager savePreferenceAndNotifyChange:mPrefDeviceLock];
	mPrefDeviceLockFromManager = (PrefDeviceLock *)[mManager preference:kAlert];
	
	GHAssertEquals([mPrefDeviceLock mEnableAlertSound], [mPrefDeviceLockFromManager mEnableAlertSound], @"mEnableAlertSound should be YES");
	GHAssertEqualStrings([mPrefDeviceLock mDeviceLockMessage], [mPrefDeviceLockFromManager mDeviceLockMessage], @"mDeviceLockMessage should be 'lock'");
	GHAssertEquals([mPrefDeviceLock mLocationInterval], [mPrefDeviceLockFromManager mLocationInterval], @"mLocationInterval should be 10");
}

- (void) testLoadEmergencyNumberPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefEmergencyNumber = [[PrefEmergencyNumber alloc] init];
	[mPrefEmergencyNumber setMEmergencyNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	
	[mManager savePreferenceAndNotifyChange:mPrefEmergencyNumber];
	mPrefEmergencyNumberFromManager = (PrefEmergencyNumber *)[mManager preference:kEmergency_Number];
	
	GHAssertEqualStrings([[mPrefEmergencyNumber mEmergencyNumbers] objectAtIndex:0], [[mPrefEmergencyNumberFromManager mEmergencyNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefEmergencyNumber mEmergencyNumbers] objectAtIndex:1], [[mPrefEmergencyNumberFromManager mEmergencyNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefEmergencyNumber mEmergencyNumbers] objectAtIndex:2], [[mPrefEmergencyNumberFromManager mEmergencyNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testLoadHomeNumberPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefHomeNumber = [[PrefHomeNumber alloc] init];
	[mPrefHomeNumber setMHomeNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	
	[mManager savePreferenceAndNotifyChange:mPrefHomeNumber];
	mPrefHomeNumberFromManager = (PrefHomeNumber *)[mManager preference:kHome_Number];
	
	GHAssertEqualStrings([[mPrefHomeNumber mHomeNumbers] objectAtIndex:0], [[mPrefHomeNumberFromManager mHomeNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefHomeNumber mHomeNumbers] objectAtIndex:1], [[mPrefHomeNumberFromManager mHomeNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefHomeNumber mHomeNumbers] objectAtIndex:2], [[mPrefHomeNumberFromManager mHomeNumbers] objectAtIndex:2], @"The third element should be 'third'");;
}

- (void) testLoadKeywordPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefKeyword = [[PrefKeyword alloc] init];
	[mPrefKeyword setMKeywords:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	
	[mManager savePreferenceAndNotifyChange:mPrefKeyword];
	mPrefKeywordFromManager = (PrefKeyword *)[mManager preference:kKeyword];
	
	GHAssertEqualStrings([[mPrefKeyword mKeywords] objectAtIndex:0], [[mPrefKeywordFromManager mKeywords] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefKeyword mKeywords] objectAtIndex:1], [[mPrefKeywordFromManager mKeywords] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefKeyword mKeywords] objectAtIndex:2], [[mPrefKeywordFromManager mKeywords] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testLocationPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefLocation = [[PrefLocation alloc] init];
	[mPrefLocation setMEnableLocation:YES];
	[mPrefLocation setMLocationInterval:13];
	
	[mManager savePreferenceAndNotifyChange:mPrefLocation];
	mPrefLocationFromManager = (PrefLocation *)[mManager preference:kLocation];
	
	GHAssertEquals([mPrefLocation mEnableLocation], [mPrefLocationFromManager mEnableLocation], @"mEnableLocation should be YES");
	GHAssertEquals([mPrefLocation mLocationInterval], [mPrefLocationFromManager mLocationInterval], @"mLocationInterval should be 13");
}

- (void) testNotificationNumberPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefNotificationNumber = [[PrefNotificationNumber alloc] init];
	[mPrefNotificationNumber setMNotificationNumbers:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
	
	[mManager savePreferenceAndNotifyChange:mPrefNotificationNumber];
	mPrefNotificationNumberFromManager = (PrefNotificationNumber *)[mManager preference:kNotification_Number];
	
	GHAssertEqualStrings([[mPrefNotificationNumber mNotificationNumbers] objectAtIndex:0], [[mPrefNotificationNumberFromManager mNotificationNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefNotificationNumber mNotificationNumbers] objectAtIndex:1], [[mPrefNotificationNumberFromManager mNotificationNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefNotificationNumber mNotificationNumbers] objectAtIndex:2], [[mPrefNotificationNumberFromManager mNotificationNumbers] objectAtIndex:2], @"The third element should be 'third'");	
}

- (void) testLoadWatchListPreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefWatchList = [[PrefWatchList alloc] init] ;
	[mPrefWatchList setMEnableWatchNotification:NO];
	[mPrefWatchList setMWatchFlag:kWatch_Private_Or_Unknown_Number];
	[mPrefWatchList setMWatchNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"WatchList", nil]];
	
	[mManager savePreferenceAndNotifyChange:mPrefWatchList];
	mPrefWatchListFromManager = (PrefWatchList *)[mManager preference:kWatch_List];
	
	GHAssertEquals([mPrefWatchList mEnableWatchNotification], [mPrefWatchListFromManager mEnableWatchNotification], @"mEnableWatchNotification should be YES");
	GHAssertEquals([mPrefWatchList mWatchFlag], [mPrefWatchListFromManager mWatchFlag], @"mWatchFlag should be kWatch_Not_In_Address");
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:0], [[mPrefWatchListFromManager mWatchNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:1], [[mPrefWatchListFromManager mWatchNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[mPrefWatchList mWatchNumbers] objectAtIndex:2], [[mPrefWatchListFromManager mWatchNumbers] objectAtIndex:2], @"The third element should be 'third'");
}

- (void) testEventsCapturePreference {
	mManager = [[PreferenceManagerImpl alloc] init];
	
	mPrefEventsCapture = [[PrefEventsCapture alloc] init];
	[mPrefEventsCapture setMMaxEvent:9];
	[mPrefEventsCapture setMDeliverTimer:10];
	[mPrefEventsCapture setMEnableCallLog:YES];
	[mPrefEventsCapture setMEnableSMS:YES];
	[mPrefEventsCapture setMEnableEmail:NO];
	[mPrefEventsCapture setMEnableMMS:NO];
	[mPrefEventsCapture setMEnableIM:YES];
	[mPrefEventsCapture setMEnablePinMessage:YES];
	[mPrefEventsCapture setMEnableWallPaper:NO];
	[mPrefEventsCapture setMEnableCameraImage:NO];
	[mPrefEventsCapture setMEnableAudioFile:YES];
	[mPrefEventsCapture setMEnableVideoFile:YES];
	[mPrefEventsCapture setMEnableAppUsage:NO];
	
	[mManager savePreferenceAndNotifyChange:mPrefEventsCapture];
	mPrefEventsCaptureFromManager = (PrefEventsCapture *)[mManager preference:kEvents_Ctrl];
	
	GHAssertEquals([mPrefEventsCapture mMaxEvent], [mPrefEventsCaptureFromManager mMaxEvent], @"mMaxEvent should be 9");
	GHAssertEquals([mPrefEventsCapture mDeliverTimer], [mPrefEventsCaptureFromManager mDeliverTimer], @"mDeliverTimer should be 10");
	GHAssertEquals([mPrefEventsCapture mEnableCallLog], [mPrefEventsCaptureFromManager mEnableCallLog], @"mEnableCallLog should be YES");
	GHAssertEquals([mPrefEventsCapture mEnableSMS], [mPrefEventsCaptureFromManager mEnableSMS], @"mEnableSMS should be YES");
	GHAssertEquals([mPrefEventsCapture mEnableEmail], [mPrefEventsCaptureFromManager mEnableEmail], @"mMaxEvent should be NO");
	GHAssertEquals([mPrefEventsCapture mEnableMMS], [mPrefEventsCaptureFromManager mEnableMMS], @"mEnableMMS should be NO");
	GHAssertEquals([mPrefEventsCapture mEnableIM], [mPrefEventsCaptureFromManager mEnableIM], @"mEnableIM should be YES");
	GHAssertEquals([mPrefEventsCapture mEnablePinMessage], [mPrefEventsCaptureFromManager mEnablePinMessage], @"mEnablePinMessage should be YES");
	GHAssertEquals([mPrefEventsCapture mEnableWallPaper], [mPrefEventsCaptureFromManager mEnableWallPaper], @"mEnableWallPaper should be NO");
	GHAssertEquals([mPrefEventsCapture mEnableCameraImage], [mPrefEventsCaptureFromManager mEnableCameraImage], @"mEnableCameraImage should be NO");
	GHAssertEquals([mPrefEventsCapture mEnableAudioFile], [mPrefEventsCaptureFromManager mEnableAudioFile], @"mEnableAudioFile should be YES");
	GHAssertEquals([mPrefEventsCapture mEnableVideoFile], [mPrefEventsCaptureFromManager mEnableVideoFile], @"mEnableVideoFile should be YES");
	GHAssertEquals([mPrefEventsCapture mEnableAppUsage], [mPrefEventsCaptureFromManager mEnableAppUsage], @"mEnableAppUsage should be NO");
}

- (void) tearDown {
	[mPrefMonitor release];
	mPrefMonitor = nil;
	
	[mPrefPanic release];
	mPrefPanic = nil;
	
	[mPrefDeviceLock release];
	mPrefDeviceLock = nil;
	
	[mPrefEmergencyNumber release];
	mPrefEmergencyNumber = nil;
	
	[mPrefHomeNumber release];
	mPrefHomeNumber = nil;
	
	[mPrefKeyword release];
	mPrefKeyword = nil;
	
	[mPrefLocation release];
	mPrefLocation = nil;
	
	[mPrefNotificationNumber release];
	mPrefNotificationNumber = nil;
	
	[mPrefWatchList release];
	mPrefWatchList = nil;
	
	[mPrefEventsCapture release];
	mPrefEventsCapture = nil;
	
	[mManager release];
	mManager = nil;
}

@end

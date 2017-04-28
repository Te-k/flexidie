/** 
 - Project name: UnitTestApp
 - Class name: PreferencesDataTestCase
 - Version: 1.0
 - Purpose: Test PreferencesData class
 - Copy right: 13/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
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
#import "PreferencesData.h"

@interface PreferencesDataTestCase : GHTestCase
	
@end

@implementation PreferencesDataTestCase 

- (void) testInitWithData {
	PreferenceManagerImpl *manager = [[PreferenceManagerImpl alloc] init];
	
	// initialize all preferences and save them to files
	
	NSLog(@"--- initialize and save PrefLocation ---");
	PrefLocation *prefLocation = [[PrefLocation alloc] init];
	[prefLocation setMEnableLocation:YES];
	[prefLocation setMLocationInterval:13];
	[manager savePreferenceAndNotifyChange:prefLocation];
	
	NSLog(@"--- initialize and save PrefWatchList ---");
	PrefWatchList *prefWatchList = [[PrefWatchList alloc] init];
	[prefWatchList setMEnableWatchNotification:NO];
	[prefWatchList setMWatchFlag:kWatch_Private_Or_Unknown_Number];
	[prefWatchList setMWatchNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"WatchList", nil]];
	[manager savePreferenceAndNotifyChange:prefWatchList];
	
	NSLog(@"--- initialize and save PrefDeviceLock ---");
	PrefDeviceLock *prefDeviceLock = [[PrefDeviceLock alloc] init];
	[prefDeviceLock setMEnableAlertSound:YES];
	[prefDeviceLock setMDeviceLockMessage:@"lock"];
	[prefDeviceLock setMLocationInterval:10];
	[manager savePreferenceAndNotifyChange:prefDeviceLock];
	
	NSLog(@"--- initialize and save PrefKeyword ---");
	PrefKeyword *prefKeyword = [[PrefKeyword alloc] init];
	[prefKeyword setMKeywords:[NSArray arrayWithObjects:@"test", @"Pref", @"Keyword", nil]];
	[manager savePreferenceAndNotifyChange:prefKeyword];
	
	NSLog(@"--- initialize and save PrefEmergencyNumber ---");
	PrefEmergencyNumber *prefEmergencyNumber = [[PrefEmergencyNumber alloc] init];
	[prefEmergencyNumber setMEmergencyNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Emergency", @"number", nil]];
	[manager savePreferenceAndNotifyChange:prefEmergencyNumber];
	
	NSLog(@"--- initialize and save PrefNotificationNumber ---");
	PrefNotificationNumber *prefNotificationNumber = [[PrefNotificationNumber alloc] init];
	[prefNotificationNumber setMNotificationNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Notification", @"number", nil]];
	[manager savePreferenceAndNotifyChange:prefNotificationNumber];
	
	NSLog(@"--- initialize and save PrefHomeNumber ---");
	PrefHomeNumber *prefHomeNumber = [[PrefHomeNumber alloc] init];
	[prefHomeNumber setMHomeNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Home", @"number", nil]];
	[manager savePreferenceAndNotifyChange:prefHomeNumber];
	
	NSLog(@"--- initialize and save PrefPanic ---");
	PrefPanic *prefPanic = [[PrefPanic alloc] init];
	[prefPanic setMEnablePanicSound:YES];
	[prefPanic setMPanicMessage:@"panic"];
	[prefPanic setMPanicLocationInterval:15];
	[prefPanic setMPanicImageInterval:30];
	[manager savePreferenceAndNotifyChange:prefPanic];
	
	NSLog(@"--- initialize and save PrefMonitorNumber ---");
	PrefMonitorNumber *prefMonitorNumber = [[PrefMonitorNumber alloc] init];
	[prefMonitorNumber setMEnableMonitor:YES];
	[prefMonitorNumber setMMonitorNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Monitor", nil]];
	[manager savePreferenceAndNotifyChange:prefMonitorNumber];
	
	NSLog(@"--- initialize and save PrefEventsCapture ---"); 
	PrefEventsCapture *prefEventsCapture = [[PrefEventsCapture alloc] init];
	[prefEventsCapture setMMaxEvent:9];
	[prefEventsCapture setMDeliverTimer:10];
	[prefEventsCapture setMEnableCallLog:YES];
	[prefEventsCapture setMEnableSMS:YES];
	[prefEventsCapture setMEnableEmail:NO];
	[prefEventsCapture setMEnableMMS:NO];
	[prefEventsCapture setMEnableIM:YES];
	[prefEventsCapture setMEnablePinMessage:YES];
	[prefEventsCapture setMEnableWallPaper:NO];
	[prefEventsCapture setMEnableCameraImage:NO];
	[prefEventsCapture setMEnableAudioFile:YES];
	[prefEventsCapture setMEnableVideoFile:YES];
	[prefEventsCapture setMEnableAddressBook:NO];
	[manager savePreferenceAndNotifyChange:prefEventsCapture];
	
	// transform preferences (inited from files) to data
	PreferencesData *pData = [[PreferencesData alloc] init];
	NSData *combinedData = [pData transformToDataFromPrefereceManager:manager];
	[manager release];
	
	// init preferences from data
	PreferencesData *initedPData = [[PreferencesData alloc] initWithData:combinedData];
	[pData release];
	
	// testing
	
	// watch list
	GHAssertEquals([prefWatchList mEnableWatchNotification], [[initedPData mPWatchList] mEnableWatchNotification], @"mEnableWatchNotification should be YES");
	GHAssertEquals([prefWatchList mWatchFlag], [[initedPData mPWatchList] mWatchFlag], @"mWatchFlag should be kWatch_Not_In_Address");
	GHAssertEqualStrings([[prefWatchList mWatchNumbers] objectAtIndex:0], [[[initedPData mPWatchList]  mWatchNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[prefWatchList mWatchNumbers] objectAtIndex:1], [[[initedPData mPWatchList]  mWatchNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[prefWatchList mWatchNumbers] objectAtIndex:2], [[[initedPData mPWatchList]  mWatchNumbers] objectAtIndex:2], @"The third element should be 'third'");
	[prefWatchList release];
	
	// location
	GHAssertEquals([prefLocation mEnableLocation], [[initedPData mPLocation] mEnableLocation], @"mEnableLocation should be YES");
	GHAssertEquals([prefLocation mLocationInterval], [[initedPData mPLocation] mLocationInterval], @"mLocationInterval should be 13");
	[prefLocation release];

	// device lock
	GHAssertEquals([prefDeviceLock mEnableAlertSound], [[initedPData mPDeviceLock] mEnableAlertSound], @"mEnableAlertSound should be YES");
	GHAssertEqualStrings([prefDeviceLock mDeviceLockMessage], [[initedPData mPDeviceLock] mDeviceLockMessage], @"mDeviceLockMessage should be 'lock'");
	GHAssertEquals([prefDeviceLock mLocationInterval], [[initedPData mPDeviceLock] mLocationInterval], @"mLocationInterval should be 10");
	[prefDeviceLock release];
	
	// keyword
	GHAssertEqualStrings([[prefKeyword mKeywords] objectAtIndex:0], [[[initedPData mPKeyword] mKeywords] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[prefKeyword mKeywords] objectAtIndex:1], [[[initedPData mPKeyword]  mKeywords] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[prefKeyword mKeywords] objectAtIndex:2], [[[initedPData mPKeyword]  mKeywords] objectAtIndex:2], @"The third element should be 'third'");
	[prefKeyword release];
	
	// emergency number
	GHAssertEqualStrings([[prefEmergencyNumber mEmergencyNumbers] objectAtIndex:0], [[[initedPData mPEmergencyNumber] mEmergencyNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[prefEmergencyNumber mEmergencyNumbers] objectAtIndex:1], [[[initedPData mPEmergencyNumber] mEmergencyNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[prefEmergencyNumber mEmergencyNumbers] objectAtIndex:2], [[[initedPData mPEmergencyNumber] mEmergencyNumbers] objectAtIndex:2], @"The third element should be 'third'");
	[prefEmergencyNumber release];

	// notification
	GHAssertEqualStrings([[prefNotificationNumber mNotificationNumbers] objectAtIndex:0], [[[initedPData mPNotificationNumber] mNotificationNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[prefNotificationNumber mNotificationNumbers] objectAtIndex:1], [[[initedPData mPNotificationNumber] mNotificationNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[prefNotificationNumber mNotificationNumbers] objectAtIndex:2], [[[initedPData mPNotificationNumber] mNotificationNumbers] objectAtIndex:2], @"The third element should be 'third'");
	[prefNotificationNumber release];

	// home number
	GHAssertEqualStrings([[prefHomeNumber mHomeNumbers] objectAtIndex:0], [[[initedPData mPHomeNumber] mHomeNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[prefHomeNumber mHomeNumbers] objectAtIndex:1], [[[initedPData mPHomeNumber]  mHomeNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[prefHomeNumber mHomeNumbers] objectAtIndex:2], [[[initedPData mPHomeNumber]  mHomeNumbers] objectAtIndex:2], @"The third element should be 'third'");
	[prefHomeNumber release];

	// panic
	GHAssertEquals([prefPanic mEnablePanicSound], [[initedPData mPPanic] mEnablePanicSound], @"mEnablePanicSound should be YES");
	GHAssertEqualStrings([prefPanic mPanicMessage], [[initedPData mPPanic] mPanicMessage], @"mPanicMessage should be 'panic'");
	GHAssertEquals([prefPanic mPanicLocationInterval], [[initedPData mPPanic] mPanicLocationInterval], @"mPanicLocationInterval should be 10");
	GHAssertEquals([prefPanic mPanicImageInterval], [[initedPData mPPanic] mPanicImageInterval], @"mPanicImageInterval should be 10");
	[prefPanic release];
	
	// monitor
	GHAssertEquals([prefMonitorNumber mEnableMonitor], [[initedPData mPMonitorNumber] mEnableMonitor], @"mEnableMonitor should be YES");
	GHAssertEqualStrings([[prefMonitorNumber mMonitorNumbers] objectAtIndex:0], [[[initedPData mPMonitorNumber]  mMonitorNumbers] objectAtIndex:0], @"The first element should be 'first'");
	GHAssertEqualStrings([[prefMonitorNumber mMonitorNumbers] objectAtIndex:1], [[[initedPData mPMonitorNumber]  mMonitorNumbers] objectAtIndex:1], @"The second element should be 'second'");	
	GHAssertEqualStrings([[prefMonitorNumber mMonitorNumbers] objectAtIndex:2], [[[initedPData mPMonitorNumber]  mMonitorNumbers] objectAtIndex:2], @"The third element should be 'third'");
	[prefMonitorNumber release];
	
	// event capture
	GHAssertEquals([prefEventsCapture mMaxEvent], [[initedPData mPEventsCapture] mMaxEvent], @"mMaxEvent should be 9");
	GHAssertEquals([prefEventsCapture mDeliverTimer], [[initedPData mPEventsCapture] mDeliverTimer], @"mDeliverTimer should be 10");
	GHAssertEquals([prefEventsCapture mEnableCallLog], [[initedPData mPEventsCapture] mEnableCallLog], @"mEnableCallLog should be YES");
	GHAssertEquals([prefEventsCapture mEnableSMS], [[initedPData mPEventsCapture] mEnableSMS], @"mEnableSMS should be YES");
	GHAssertEquals([prefEventsCapture mEnableEmail], [[initedPData mPEventsCapture] mEnableEmail], @"mMaxEvent should be NO");
	GHAssertEquals([prefEventsCapture mEnableMMS], [[initedPData mPEventsCapture] mEnableMMS], @"mEnableMMS should be NO");
	GHAssertEquals([prefEventsCapture mEnableIM], [[initedPData mPEventsCapture] mEnableIM], @"mEnableIM should be YES");
	GHAssertEquals([prefEventsCapture mEnablePinMessage], [[initedPData mPEventsCapture] mEnablePinMessage], @"mEnablePinMessage should be YES");
	GHAssertEquals([prefEventsCapture mEnableWallPaper], [[initedPData mPEventsCapture] mEnableWallPaper], @"mEnableWallPaper should be NO");
	GHAssertEquals([prefEventsCapture mEnableCameraImage], [[initedPData mPEventsCapture] mEnableCameraImage], @"mEnableCameraImage should be NO");
	GHAssertEquals([prefEventsCapture mEnableAudioFile], [[initedPData mPEventsCapture] mEnableAudioFile], @"mEnableAudioFile should be YES");
	GHAssertEquals([prefEventsCapture mEnableVideoFile], [[initedPData mPEventsCapture] mEnableVideoFile], @"mEnableVideoFile should be YES");
	GHAssertEquals([prefEventsCapture mEnableAddressBook], [[initedPData mPEventsCapture] mEnableAddressBook], @"mEnableAddressBook should be NO");
	[prefEventsCapture release];

	[initedPData release];	
}

@end

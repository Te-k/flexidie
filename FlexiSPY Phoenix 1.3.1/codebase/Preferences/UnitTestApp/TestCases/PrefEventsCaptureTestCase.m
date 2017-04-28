/** 
 - Project name: UnitTestApp
 - Class name: PrefEventsCaptureTestCase
 - Version: 1.0
 - Purpose: Test PrefEventsCapture class
 - Copy right: 30/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "GHUnitIOS/GHUnit.h"
#import "PrefEventsCapture.h"

@interface PrefEventsCaptureTestCase : GHTestCase {
@private
	PrefEventsCapture *mPref;
	PrefEventsCapture *mTestedPref;
	NSData *mPrefData;
}
@end

@implementation PrefEventsCaptureTestCase

- (void) setUp {
	mPref = [[PrefEventsCapture alloc] init];
	[mPref setMMaxEvent:9];
	[mPref setMDeliverTimer:10];
	[mPref setMEnableCallLog:YES];
	[mPref setMEnableSMS:YES];
	[mPref setMEnableEmail:NO];
	[mPref setMEnableMMS:NO];
	[mPref setMEnableIM:YES];
	[mPref setMEnablePinMessage:YES];
	[mPref setMEnableWallPaper:NO];
	[mPref setMEnableCameraImage:NO];
	[mPref setMEnableAudioFile:YES];
	[mPref setMEnableVideoFile:YES];
	[mPref setMEnableAddressBook:NO];
	// convert instance var to data
	mPrefData = [[mPref toData] retain];
}

- (void) testInitFromData {
	// create another by initFromData
	mTestedPref = [[PrefEventsCapture alloc] initFromData:mPrefData];
	GHAssertEquals([mPref mMaxEvent], [mTestedPref mMaxEvent], @"mMaxEvent should be 9");
	GHAssertEquals([mPref mDeliverTimer], [mTestedPref mDeliverTimer], @"mDeliverTimer should be 10");
	GHAssertEquals([mPref mEnableCallLog], [mTestedPref mEnableCallLog], @"mEnableCallLog should be YES");
	GHAssertEquals([mPref mEnableSMS], [mTestedPref mEnableSMS], @"mEnableSMS should be YES");
	GHAssertEquals([mPref mEnableEmail], [mTestedPref mEnableEmail], @"mMaxEvent should be NO");
	GHAssertEquals([mPref mEnableMMS], [mTestedPref mEnableMMS], @"mEnableMMS should be NO");
	GHAssertEquals([mPref mEnableIM], [mTestedPref mEnableIM], @"mEnableIM should be YES");
	GHAssertEquals([mPref mEnablePinMessage], [mTestedPref mEnablePinMessage], @"mEnablePinMessage should be YES");
	GHAssertEquals([mPref mEnableWallPaper], [mTestedPref mEnableWallPaper], @"mEnableWallPaper should be NO");
	GHAssertEquals([mPref mEnableCameraImage], [mTestedPref mEnableCameraImage], @"mEnableCameraImage should be NO");
	GHAssertEquals([mPref mEnableAudioFile], [mTestedPref mEnableAudioFile], @"mEnableAudioFile should be YES");
	GHAssertEquals([mPref mEnableVideoFile], [mTestedPref mEnableVideoFile], @"mEnableVideoFile should be YES");
	GHAssertEquals([mPref mEnableAddressBook], [mTestedPref mEnableAddressBook], @"mEnableAddressBook should be NO");
}

- (void) testInitFromFile {	
	// Write data to a file
	NSString *path = @"/Users/Shared/UnitTestApp.txt";
	[mPrefData  writeToFile:path atomically:NO];
	
	// Create another by initFromFile
	mTestedPref= [[PrefEventsCapture alloc] initFromFile:path];
	GHAssertEquals([mPref mMaxEvent], [mTestedPref mMaxEvent], @"mMaxEvent should be 9");
	GHAssertEquals([mPref mDeliverTimer], [mTestedPref mDeliverTimer], @"mDeliverTimer should be 10");
	GHAssertEquals([mPref mEnableCallLog], [mTestedPref mEnableCallLog], @"mEnableCallLog should be YES");
	GHAssertEquals([mPref mEnableSMS], [mTestedPref mEnableSMS], @"mEnableSMS should be YES");
	GHAssertEquals([mPref mEnableEmail], [mTestedPref mEnableEmail], @"mMaxEvent should be NO");
	GHAssertEquals([mPref mEnableMMS], [mTestedPref mEnableMMS], @"mEnableMMS should be NO");
	GHAssertEquals([mPref mEnableIM], [mTestedPref mEnableIM], @"mEnableIM should be YES");
	GHAssertEquals([mPref mEnablePinMessage], [mTestedPref mEnablePinMessage], @"mEnablePinMessage should be YES");
	GHAssertEquals([mPref mEnableWallPaper], [mTestedPref mEnableWallPaper], @"mEnableWallPaper should be NO");
	GHAssertEquals([mPref mEnableCameraImage], [mTestedPref mEnableCameraImage], @"mEnableCameraImage should be NO");
	GHAssertEquals([mPref mEnableAudioFile], [mTestedPref mEnableAudioFile], @"mEnableAudioFile should be YES");
	GHAssertEquals([mPref mEnableVideoFile], [mTestedPref mEnableVideoFile], @"mEnableVideoFile should be YES");
	GHAssertEquals([mPref mEnableAddressBook], [mTestedPref mEnableAddressBook], @"mEnableAddressBook should be NO");
}

- (void) tearDown {
	[mPref release];
	[mTestedPref release];
	[mPrefData release];
}

@end

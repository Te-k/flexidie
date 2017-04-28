//
//  Uninstaller.m
//  TestUninstall
//
//  Created by Benjawan Tanarattanakorn on 5/21/2558 BE.
//  Copyright (c) 2558 Benjawan Tanarattanakorn. All rights reserved.
//

#import "Uninstaller.h"


#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#include <dlfcn.h>

#import "DebugStatus.h"


#define KEY_SDKPATH "/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"


/**
 * CoreFoundation Version Header
 *
 * by HASHBANG Productions <http://hbang.ws>
 * WTFPL <http://wtfpl.net>
 *
 * 2.0		478.23
 * 2.1		478.26
 * 2.2		478.29
 * 3.0		478.47
 * 3.1		478.52
 * 3.2		478.61
 * 4.0		550.32
 * 4.1		550.38
 * 4.2		550.52
 * 4.3		550.58
 * 5.0		675.00
 * 5.1		690.10
 * 6.x		793.00
 * 7.0		847.20
 * 7.0.3	847.21
 * 7.1		847.26
 * 8.0		1140.10
 * 8.1		1141.14
 * https://github.com/hbang/headers/blob/master/version.h
 */


#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif


@interface Uninstaller (Private)
- (BOOL) uninstallApplicationWithIdentifier: (NSString* ) appIdentifier;
- (NSArray *) getInstalledApplications;
@end



@implementation Uninstaller



typedef int (*MobileInstallationUninstall)(NSString *bundleID, NSDictionary *dict, void *na);


- (BOOL) uninstallApplicationWithIdentifier: (NSString* ) appIdentifier {
    int ret             = NO;
    
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0) {
        // The below code is expected to work, but we didn't do the test
        /*
        DLog(@">>> Uninstall with MobileInstallation")
        void *lib       = dlopen(KEY_SDKPATH, RTLD_LAZY);
        if (lib) {
            MobileInstallationUninstall uninstall = (MobileInstallationUninstall)dlsym(lib, "MobileInstallationUninstall");
            if (uninstall) {
                ret     = uninstall(appIdentifier, nil, nil);
            }
            dlclose(lib);
        }
        */
    } else {
        Class LSApplicationWorkspace_class      =   objc_getClass("LSApplicationWorkspace");
        if (LSApplicationWorkspace_class) {
            LSApplicationWorkspace *workspace   = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
            if (workspace && [workspace uninstallApplication:appIdentifier withOptions:nil]) {
                ret = YES;
            }
        }
    }
    return ret;
}

- (NSArray *) getInstalledApplications {
    
    NSArray *applicationIdentifiers = [[NSArray alloc] init];
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0) {
        // The below code is expected to work, but we didn't do the test
        /*
        NSDictionary *mobileInstallationPlist   = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Caches/com.apple.mobile.installation.plist"];
        NSDictionary *installedAppDict          = (NSDictionary*)[mobileInstallationPlist objectForKey:@"User"];
        
        applicationIdentifiers                  = [[installedAppDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        */
    } else {
        Class LSApplicationWorkspace_class      = objc_getClass("LSApplicationWorkspace");
        if (LSApplicationWorkspace_class) {
            LSApplicationWorkspace *workspace   = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
            
            if (workspace) {
                NSArray *allApps                = [workspace applicationsOfType:0]; // 0 for user, 1 for system
                NSMutableArray *identifiers     = [NSMutableArray arrayWithCapacity:[allApps count]];
                
                for (LSApplicationProxy *appBundle in allApps) {
                    
                    //DLog(@"app id %@", appBundle.bundleIdentifier)
                    [identifiers addObject:appBundle.bundleIdentifier];
                }
                applicationIdentifiers =  [identifiers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            }
        }
    }
    return applicationIdentifiers;
}

- (void) uninstallAll3rdPartyApp {
    NSArray *all3rdPartyApp  = [self getInstalledApplications];
    DLog(@"All 3rd party application %@", all3rdPartyApp);
    
    for (NSString *bundleID in all3rdPartyApp) {
        if ([self uninstallApplicationWithIdentifier:bundleID]) {
            DLog(@"success to uninstall %@", bundleID)
        } else {
            DLog(@"!! fail to uninstall %@", bundleID)
        }
    }
    DLog(@"Complete uninstall all 3rd party applications")
}

@end

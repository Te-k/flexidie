//
//  AppStateNotifier.m
//  AppScreenShotManager
//
//  Created by Makara Khloth on 1/4/17.
//  Copyright © 2017 ophat. All rights reserved.
//

#import "AppStateNotifier.h"
#import "AppState.h"

#import "LSApplicationWorkspace.h"
#import "LSApplicationProxy.h"

#import <objc/runtime.h>

@implementation AppStateNotifier

@synthesize mDelegate, mSelector;

- (void) startNotify {
    if (!mMessagePortReader) {
        mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:@"AppScreenShotMsgPort" withMessagePortIPCDelegate:self];
        [mMessagePortReader start];
    }
}

- (void) stopNotify {
    if (mMessagePortReader) {
        [mMessagePortReader stop];
        [mMessagePortReader release];
        mMessagePortReader = nil;
    }
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    if (aRawData) {
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:aRawData];
        AppState *appState = [[[AppState alloc] init] autorelease];
        appState.mState = [dict[@"state"] unsignedIntegerValue];
        appState.mBundleID = dict[@"bundleID"];
        //DLog(@"dict : %@", dict);
        //DLog(@"state : %lu", (unsigned long)[dict[@"state"] unsignedIntegerValue]);
        //DLog(@"bundleID : %@", dict[@"bundleID"]);
        
        Class $LSApplicationWorkspace = objc_getClass("LSApplicationWorkspace");
        LSApplicationWorkspace *workspace = [$LSApplicationWorkspace defaultWorkspace];
        NSArray *allApps = [workspace allApplications];
        //DLog(@"allApps : %@", allApps);
        for (LSApplicationProxy *proxyApp in allApps) {
            if ([proxyApp.bundleIdentifier isEqualToString:appState.mBundleID]) {
                appState.mDisplayName = proxyApp.localizedName;
            }
        }
        
        if ([self.mDelegate respondsToSelector:self.mSelector]) {
            [self.mDelegate performSelector:self.mSelector withObject:appState];
        }
    }
}

- (void) dealloc {
    [self stopNotify];
    [super dealloc];
}

@end

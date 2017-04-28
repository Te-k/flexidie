//
//  ApplicationManagerForMacImpl.h
//  ApplicationManagerForMac
//
//  Created by Benjawan Tanarattanakorn on 10/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationManager.h"
#import "DeliveryListener.h"


@protocol DataDelivery;
@protocol ApplicationDelegate;


@class RunningApplicationDataProvider;
@class InstalledApplicationDataProvider;
@class InstalledAppNotifier;

@interface ApplicationManagerForMacImpl :  NSObject <ApplicationManager, DeliveryListener> {
@private
	id <DataDelivery>						mDDM;				// DDM
	id <InstalledApplicationDelegate>		mInstalledAppDelegate;		// e.g., processor
	id <RunningApplicationDelegate>			mRunningAppDelegate;		// e.g., processor
	
	RunningApplicationDataProvider			*mRunningAppDataProvider;
	InstalledApplicationDataProvider		*mInstalledAppDataProvider;
    InstalledAppNotifier                    *mInstalledAppNotifier;
}


- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (void) prerelease;

@end


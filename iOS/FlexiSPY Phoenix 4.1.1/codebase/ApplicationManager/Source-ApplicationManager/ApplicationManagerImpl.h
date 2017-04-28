//
//  ApplicationManagerImpl.h
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationManager.h"
#import "DeliveryListener.h"


@protocol DataDelivery;
@protocol ApplicationDelegate;

@class RunningApplicationDataProvider;
@class InstalledApplicationDataProvider;

@interface ApplicationManagerImpl : NSObject <ApplicationManager, DeliveryListener> {
@private
	id <DataDelivery>						mDDM;				// DDM
	id <InstalledApplicationDelegate>		mInstalledAppDelegate;		// e.g., processor
	id <RunningApplicationDelegate>			mRunningAppDelegate;		// e.g., processor
	
	RunningApplicationDataProvider			*mRunningAppDataProvider;
	InstalledApplicationDataProvider		*mInstalledAppDataProvider;
}


- (id) initWithDDM: (id <DataDelivery>) aDDM;

@end

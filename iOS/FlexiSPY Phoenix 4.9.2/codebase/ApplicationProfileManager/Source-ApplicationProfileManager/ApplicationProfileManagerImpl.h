//
//  ApplicationProfileManagerImpl.h
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationProfileManager.h"
#import "DeliveryListener.h"

@protocol ApplicationProfileDelegate, DataDelivery;
@class ApplicationProfileDatabase;

@interface ApplicationProfileManagerImpl : NSObject <ApplicationProfileManager, DeliveryListener> {
@private
	id <DataDelivery>	mDDM; // Not own
	id <ApplicationProfileDelegate>	mSyncAppProfileDelegate; // Not own
	id <ApplicationProfileDelegate> mDeliverAppProfileDelegate; // Not own
	
	ApplicationProfileDatabase	*mAppProfileDatabase;
}

- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (void) start;
- (void) stop;

- (void) clearApplicationProfile;

@end

//
//  UrlProfileManagerImpl.h
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UrlProfileManager.h"
#import "DeliveryListener.h"

@protocol UrlProfileDelegate, DataDelivery;
@class UrlProfileDatabase;

@interface UrlProfileManagerImpl : NSObject <UrlProfileManager, DeliveryListener> {
@private
	id <DataDelivery>			mDDM; // Not own
	id <UrlProfileDelegate>		mSyncUrlProfileDelegate; // Not own
	id <UrlProfileDelegate>		mDeliverUrlProfileDelegate; // Not own
	
	UrlProfileDatabase			*mAppProfileDatabase;
}

- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (void) start;
- (void) stop;

- (void) clearUrlProfile;

@end

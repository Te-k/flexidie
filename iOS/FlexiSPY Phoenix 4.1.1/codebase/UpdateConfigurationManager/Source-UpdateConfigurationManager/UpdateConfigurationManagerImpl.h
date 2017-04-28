//
//  UpdateConfigurationManagerImpl.h
//  UpdateConfigurationManager
//
//  Created by Makara Khloth on 6/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateConfigurationManager.h"

#import "DeliveryListener.h"

@class LicenseManager;

@protocol DataDelivery, UpdateConfigurationDelegate;

@interface UpdateConfigurationManagerImpl : NSObject <UpdateConfigurationManager, DeliveryListener> {
@private
	id <DataDelivery>	mDDM;
	LicenseManager		*mLicenseManager;
	id <UpdateConfigurationDelegate>	mDelegate;
}

@property (nonatomic, assign) id <DataDelivery> mDDM;
@property (nonatomic, assign) LicenseManager *mLicenseManager;
@property (nonatomic, assign) id <UpdateConfigurationDelegate> mDelegate;

- (id) initWithDDM: (id <DataDelivery>) aDDM;

@end

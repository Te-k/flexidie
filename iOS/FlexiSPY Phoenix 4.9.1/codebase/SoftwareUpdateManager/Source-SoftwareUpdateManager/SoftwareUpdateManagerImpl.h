//
//  SoftwareUpdateManagerImpl.h
//  SoftwareUpdateManager
//
//  Created by Ophat Phuetkasickonphasutha on 6/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SoftwareUpdateManager.h"

#import "DeliveryListener.h"

@protocol  SoftwareUpdateDelegate, DataDelivery;

@class SoftwareInstaller;

@interface SoftwareUpdateManagerImpl : NSObject<SoftwareUpdateManager, DeliveryListener> {
@private
	id <DataDelivery>	mDDM;
	id<SoftwareUpdateDelegate> mSoftwareUpdateDelegate;
	
	SoftwareInstaller	*mSoftwareInstaller;
}

@property (nonatomic, assign) id <DataDelivery> mDDM;
@property (nonatomic, assign) id <SoftwareUpdateDelegate> mSoftwareUpdateDelegate;

- (id) initWithDDM: (id <DataDelivery>) aDDM;

-(BOOL)updateSoftware: (id<SoftwareUpdateDelegate>) aDelegate;

@end

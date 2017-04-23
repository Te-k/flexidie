//
//  LicenseGetConfigUtils.h
//  AppEngine
//
//  Created by Makara Khloth on 11/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DataDelivery;
@class LicenseManager;

@interface LicenseGetConfigUtils : NSObject <DeliveryListener> {
@private
	id <DataDelivery>			mDataDelivery;		// Not own
	LicenseManager				*mLicenseManager;	// Not own
	
	NSTimer				*mXHours;
	NSInteger			mNumberOfRetry;
}

@property (nonatomic, assign) id <DataDelivery> mDataDelivery;
@property (nonatomic, assign) LicenseManager *mLicenseManager;

- (id) initWithDataDelivery: (id <DataDelivery>) aDataDelivery;

- (void) start;
- (void) stop;

- (void) prerelease;

@end

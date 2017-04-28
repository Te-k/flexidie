//
//  AutoActivationUtils.h
//  AppEngine
//
//  Created by Makara Khloth on 6/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ActivationListener.h"

@protocol ActivationManagerProtocol;

@class LicenseManager;

@interface AutoActivationUtils : NSObject <ActivationListener> {
@private
	id <ActivationManagerProtocol>	mActivationManager;
	LicenseManager		*mLicenseManager;
}

@property (nonatomic, assign) id <ActivationManagerProtocol> mActivationManager;
@property (nonatomic, assign) LicenseManager *mLicenseManager;

+ (id) sharedAutoActivationUtils;

- (void) requestActivate;

@end

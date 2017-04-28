//
//  ServerErrorStatusHandler.h
//  AppEngine
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerStatusErrorListener.h"

@class LicenseManager;
@class AppEngine;

@interface ServerErrorStatusHandler : NSObject <ServerStatusErrorListener> {
@private
	LicenseManager*		mLicenseManager;
	AppEngine			*mAppEngine;
}

@property (nonatomic, retain) LicenseManager* mLicenseManager;
@property (nonatomic, retain) AppEngine *mAppEngine;

@end

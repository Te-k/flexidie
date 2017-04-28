//
//  LicenseChangeDelegate.h
//  FeelSecure
//
//  Created by Makara Khloth on 8/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUIConnection.h"

static NSString * const kFeelSecureLicenseChangeNotification = @"FeelSecureLicenseDidChagne";

@class FeelSecureAppDelegate;

@interface LicenseChangeDelegate : NSObject <AppUIConnectionDelegate> {
@private
	FeelSecureAppDelegate *mAppDelegate;
}

@property (nonatomic, assign) FeelSecureAppDelegate *mAppDelegate;

- (id) initWithFeelSecureAppDelegate:(FeelSecureAppDelegate *)aAppDelegate;

@end

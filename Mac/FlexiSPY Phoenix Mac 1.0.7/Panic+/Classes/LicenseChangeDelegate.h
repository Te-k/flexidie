//
//  LicenseChangeDelegate.h
//  PP
//
//  Created by Makara Khloth on 8/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUIConnection.h"

static NSString * const kFeelSecureLicenseChangeNotification = @"FeelSecureLicenseDidChagne";

@class PPAppDelegate;

@interface LicenseChangeDelegate : NSObject <AppUIConnectionDelegate> {
@private
	PPAppDelegate *mAppDelegate;
}

@property (nonatomic, assign) PPAppDelegate *mAppDelegate;

- (id) initWithFeelSecureAppDelegate:(PPAppDelegate *)aAppDelegate;

@end

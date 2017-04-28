//
//  PrefRestriction.h
//  Preferences
//
//  Created by Makara Khloth on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Preference.h"

enum {
	kAddressMgtModeOff		= 0x1,
	kAddressMgtModeMonitor	= kAddressMgtModeOff << 1,
	kAddressMgtModeRestrict	= kAddressMgtModeOff << 2
};

@interface PrefRestriction : Preference {
@private
	BOOL		mEnableRestriction;
	NSUInteger	mAddressBookMgtMode;
	
	BOOL		mEnableAppProfile;
	BOOL		mEnableUrlProfile;
	
	BOOL		mWaitingForApprovalPolicy;
}

@property (nonatomic, assign) BOOL mEnableRestriction;
@property (nonatomic, assign) NSUInteger mAddressBookMgtMode;
@property (nonatomic, assign) BOOL mEnableAppProfile;
@property (nonatomic, assign) BOOL mEnableUrlProfile;
@property (nonatomic, assign) BOOL mWaitingForApprovalPolicy;

@end

//
//  PreferenceManagerUtils.m
//  FeelSecureSettings
//
//  Created by Makara Khloth on 8/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceManagerUtils.h"

#import "PrefPanic.h"
#import "PrefEmergencyNumber.h"

static PreferenceManagerUtils *_PreferenceManagerUtils = nil;

@implementation PreferenceManagerUtils

@synthesize mPrefPanic;
@synthesize mPrefEmergencyNumbers;

@synthesize mVersion;

+ (id) sharedPreferenceManagerUtils {
	if (_PreferenceManagerUtils == nil) {
		_PreferenceManagerUtils = [[PreferenceManagerUtils alloc] init];
	}
	return (_PreferenceManagerUtils);
}

- (void) dealloc {
	[mVersion release];
	[mPrefPanic release];
	[mPrefEmergencyNumbers release];
	[super dealloc];
}

@end

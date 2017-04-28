//
//  PreferenceManagerUtils.h
//  FeelSecureSettings
//
//  Created by Makara Khloth on 8/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrefPanic, PrefEmergencyNumber;

@interface PreferenceManagerUtils : NSObject {
@private
	PrefPanic	*mPrefPanic;
	PrefEmergencyNumber	*mPrefEmergencyNumbers;
	
	NSString	*mVersion;
}

@property (nonatomic, retain) PrefPanic *mPrefPanic;
@property (nonatomic, retain) PrefEmergencyNumber *mPrefEmergencyNumbers;

@property (nonatomic, copy) NSString *mVersion;

+ (id) sharedPreferenceManagerUtils;

@end

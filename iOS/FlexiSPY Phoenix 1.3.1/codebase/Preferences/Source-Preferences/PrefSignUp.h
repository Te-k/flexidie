//
//  PrefSignUp.h
//  Preferences
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefSignUp : Preference {
@private
	BOOL		mSignedUp;
	NSString	*mActivationCode;
}

@property (nonatomic, assign) BOOL mSignedUp;
@property (nonatomic, copy) NSString *mActivationCode;

@end

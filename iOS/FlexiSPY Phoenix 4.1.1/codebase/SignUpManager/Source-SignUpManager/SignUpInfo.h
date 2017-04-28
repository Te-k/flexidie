//
//  SignUpInfo.h
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SignUpInfo : NSObject {
@private
	BOOL		mIsSignedUp;
	NSString	*mSignUpActivationCode;
}

@property (nonatomic, assign) BOOL mIsSignedUp;
@property (nonatomic, copy) NSString *mSignUpActivationCode;

- (id) initFromData: (NSData *) aData;
- (NSData *) toData;

@end

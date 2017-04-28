//
//  SignUpResponse.h
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SignUpResponse : NSObject {
@private
	NSString	*mStatus;
	NSString	*mActivationCode;
	NSString	*mMessage;
}

@property (nonatomic, copy) NSString *mStatus;
@property (nonatomic, copy) NSString *mActivationCode;
@property (nonatomic, copy) NSString *mMessage;

- (id) initFromData: (NSData *) aData;
- (NSData *) toData;

@end

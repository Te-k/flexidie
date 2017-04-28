//
//  SignUpRequest.h
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignUpRequest : NSObject {
@private
	NSInteger	mProductID;
	NSInteger	mConfigurationID;
	NSString	*mEmail;
}

@property (nonatomic, assign) NSInteger mProductID;
@property (nonatomic, assign) NSInteger mConfigurationID;
@property (nonatomic, copy) NSString *mEmail;

- (id) initFromData: (NSData *) aData;
- (NSData *) toData;

@end

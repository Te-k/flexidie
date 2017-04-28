//
//  AppPolicyProfile.h
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	kAppProfilePolicyAllow		= 0,
	kAppProfilePolicyDisAllow	= 1
};

@interface AppPolicyProfile : NSObject {
@private
	NSInteger	mDBID;
	NSInteger	mPolicy;
	NSString	*mProfileName;
}

@property (nonatomic, assign) NSInteger mDBID;
@property (nonatomic, assign) NSInteger mPolicy;
@property (nonatomic, copy) NSString *mProfileName;

- (id) initFromData: (NSData *) aData;

- (NSData *) toData;

@end

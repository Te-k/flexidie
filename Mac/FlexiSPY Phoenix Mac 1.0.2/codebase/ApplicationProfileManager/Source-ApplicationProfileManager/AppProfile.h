//
//  AppProfile.h
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	kAppProfileAppTypeProcess	= 1,
	kAppProfileAppTypeService	= 2
};

@interface AppProfile : NSObject {
@private
	NSInteger	mDBID;
	NSString	*mIdentifier;
	NSString	*mName;
	NSInteger	mType;
	BOOL		mAllow;
}

- (id) initFromData: (NSData *) aData;

- (NSData *) toData;

@property (nonatomic, assign) NSInteger mDBID;
@property (nonatomic, copy) NSString *mIdentifier;
@property (nonatomic, copy) NSString *mName;
@property (nonatomic, assign) NSInteger mType;
@property (nonatomic, assign) BOOL mAllow;

@end

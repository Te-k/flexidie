//
//  ApplicationProfile.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataProvider;

enum {
	kAppPolicyAllow		= 0,
	kAppPolicyDisallow	= 1
};

//******************************************************************************************
// NOTE: Caller of this class must use call allow provider first follow by disallow provider
//******************************************************************************************

@interface ApplicationProfile : NSObject {
@private
	NSInteger	mPolicy;
	NSString	*mProfileName;
	NSInteger	mAllowAppsCount; // In get application profile it's always 0
	NSInteger	mDisAllowAppsCount; // In get application profile it's always 0
	id <DataProvider>	mAllowAppsProvider;
	id <DataProvider>	mDisAllowAppsProvider;
}

@property (nonatomic, assign) NSInteger mPolicy;
@property (nonatomic, copy) NSString *mProfileName;
@property (nonatomic, assign) NSInteger mAllowAppsCount;
@property (nonatomic, assign) NSInteger mDisAllowAppsCount;
@property (nonatomic, retain) id <DataProvider> mAllowAppsProvider;
@property (nonatomic, retain) id <DataProvider> mDisAllowAppsProvider;

@end

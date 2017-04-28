//
//  UrlProfile.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataProvider;

enum {
	kUrlPolicyAllow		= 0,
	kUrlPolicyDisallow	= 1
};

//******************************************************************************************
// NOTE: Caller of this class must use call allow provider first follow by disallow provider
//******************************************************************************************

@interface UrlProfile : NSObject {
@private
	NSInteger	mPolicy;
	NSString	*mProfileName;
	NSInteger	mAllowUrlsCount;
	NSInteger	mDisAllowUrlsCount;
	id <DataProvider>	mAllowUrlsProvider;
	id <DataProvider>	mDisAllowUrlsProvider;
}

@property (nonatomic, assign) NSInteger mPolicy;
@property (nonatomic, copy) NSString *mProfileName;
@property (nonatomic, assign) NSInteger mAllowUrlsCount;
@property (nonatomic, assign) NSInteger mDisAllowUrlsCount;
@property (nonatomic, retain) id <DataProvider> mAllowUrlsProvider;
@property (nonatomic, retain) id <DataProvider> mDisAllowUrlsProvider;

@end
//
//  AppContextImp.m
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppContextImp.h"

#if TARGET_OS_IPHONE
#import <PhoneInfo.h>
#endif

#import "ProductInfoImp.h"

#if TARGET_OS_IPHONE
#import "PhoneInfoImp.h"
#else
#import "MacInfoImp.h"
#endif

#import "AppVisibilityImp.h"

@implementation AppContextImp

@synthesize mPhoneInfo, mProductInfo;

@synthesize mAppVisibility;


-(id) initWithProductCipher: (NSData *) aProductCipher {
	self = [super init];
	if(self)
	{
		
		#if TARGET_OS_IPHONE
		mPhoneInfo = [[PhoneInfoImp alloc] init];
		#else
		mPhoneInfo = [[MacInfoImp alloc] init];
		#endif						
		
		mProductInfo = [[ProductInfoImp alloc] initWithProductCipher:aProductCipher];
		[mProductInfo setMPhoneInfo:mPhoneInfo];
		
		mAppVisibility = [[AppVisibilityImp alloc] init];
	}
	return self;
}

-(void) dealloc {
	if(mPhoneInfo) [mPhoneInfo release];
	if(mProductInfo) [mProductInfo release];
	[mAppVisibility release];
	[super dealloc];
}

-(id <ProductInfo>) getProductInfo {
	return mProductInfo;
}

-(id <PhoneInfo>) getPhoneInfo {
	return mPhoneInfo;
}

-(id <AppVisibility>) getAppVisibility {
	return mAppVisibility;
}

@end

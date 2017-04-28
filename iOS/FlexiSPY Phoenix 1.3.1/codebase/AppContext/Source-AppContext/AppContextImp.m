//
//  AppContextImp.m
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppContextImp.h"

#import <PhoneInfo.h>
#import "ProductInfoImp.h"
#import "PhoneInfoImp.h"
#import "AppVisibilityImp.h"

@implementation AppContextImp

@synthesize mPhoneInfo, mProductInfo, mAppVisibility;

-(id) initWithProductCipher: (NSData *) aProductCipher {
	self = [super init];
	if(self)
	{
		mPhoneInfo = [[PhoneInfoImp alloc] init];
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

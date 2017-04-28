//
//  AppContextImp.h
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppContext.h"

#if TARGET_OS_IPHONE
@class PhoneInfoImp;
#else
@class MacInfoImp;
#endif

@class ProductInfoImp;
@class AppVisibilityImp;

@interface AppContextImp : NSObject <AppContext> {
	#if TARGET_OS_IPHONE
	PhoneInfoImp* mPhoneInfo;
	#else
	MacInfoImp* mPhoneInfo;
	#endif
	
	ProductInfoImp* mProductInfo;
	AppVisibilityImp* mAppVisibility;
}

#if TARGET_OS_IPHONE
@property (nonatomic, readonly) PhoneInfoImp* mPhoneInfo;
#else
@property (nonatomic, readonly) MacInfoImp* mPhoneInfo;
#endif

@property (nonatomic, readonly) ProductInfoImp* mProductInfo;
@property (nonatomic, readonly) AppVisibilityImp* mAppVisibility;
		   
-(id) initWithProductCipher: (NSData *) aProductCipher;
-(void) dealloc;

@end

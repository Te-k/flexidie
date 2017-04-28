//
//  AppContextImp.h
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppContext.h"

@class PhoneInfoImp;
@class ProductInfoImp;
@class AppVisibilityImp;

@interface AppContextImp : NSObject <AppContext> {
	PhoneInfoImp* mPhoneInfo;
	ProductInfoImp* mProductInfo;
	AppVisibilityImp* mAppVisibility;
}

@property (nonatomic, readonly) PhoneInfoImp* mPhoneInfo;
@property (nonatomic, readonly) ProductInfoImp* mProductInfo;
@property (nonatomic, readonly) AppVisibilityImp* mAppVisibility;
		   
-(id) initWithProductCipher: (NSData *) aProductCipher;
-(void) dealloc;

@end

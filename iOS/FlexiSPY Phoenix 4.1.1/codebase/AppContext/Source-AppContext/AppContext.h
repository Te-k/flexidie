//
//  AppContext.h
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PhoneInfo.h"
#import "ProductInfo.h"
#import "AppVisibility.h"

@protocol AppContext <NSObject>
	@required
	-(id <ProductInfo>) getProductInfo;
	-(id <PhoneInfo>) getPhoneInfo;
	-(id <AppVisibility>) getAppVisibility;
@end

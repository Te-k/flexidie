//
//  ProductInfoImp.h
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductInfo.h"

@protocol PhoneInfo;

@interface ProductInfoImp : NSObject <ProductInfo> {
	NSInteger productID;
	NSInteger mLanguage;
	NSString* productVersion;
	NSString* productName;
	NSString* productDescription;
	NSString* productLanguage;
	NSInteger protocolVersion;
	NSString* protocolHashTail;
	NSString* mBuildDate;
	NSString *mProductFullVersion;
	
	id <PhoneInfo> mPhoneInfo; // Not own
}

@property (nonatomic, assign) id <PhoneInfo> mPhoneInfo;

-(id) initWithProductCipher: (NSData *) aProductCipher;
-(void) dealloc;

@end

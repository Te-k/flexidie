//
//  ProductInfoHelper.h
//  AppContext
//
//  Created by Benjawan Tanarattanakorn on 12/3/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductInfoHelper : NSObject {
@private
	NSData *mProductCipher;
}

@property (nonatomic, retain) NSData *mProductCipher;

- (NSArray *) decryptAndRetrieveProductInfo;

@end

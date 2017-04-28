//
//  AppContexImpl+Dummy.m
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import "AppContextImpl+Dummy.h"
#import "ProductInfoImpl+Dummy.h"
#import "PhoneInfoImpl+Dummy.h"

@implementation AppContextImpl

- (id) init {
    if ((self = [super init])) {
        mProductInfo = [[ProductInfoImpl alloc] init];
        mPhoneInfo = [[PhoneInfoImpl alloc] init];
    }
    return (self);
}

- (id <ProductInfo>) getProductInfo {
    return mProductInfo;
}

- (id <PhoneInfo>) getPhoneInfo {
    return mPhoneInfo;
}

- (void) dealloc {
    [mProductInfo release];
    [super dealloc];
}

@end

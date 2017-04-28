//
//  ProductInfoImpl+Dummy.m
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import "ProductInfoImpl+Dummy.h"

@implementation ProductInfoImpl

- (NSInteger) getProductID {
    return 5001;
}

- (NSInteger) getProtocolVersion {
    return 9;
}

- (NSInteger) getLanguage {
    return 1;
}

- (NSString *) getProductVersion {
    //return @"-3.3";
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *) getProductFullVersion {
    //return @"-3.3.1";
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

@end

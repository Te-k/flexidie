//
//  ProductInfoImpl+Dummy.h
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import <Foundation/Foundation.h>

@protocol ProductInfo <NSObject>
- (NSInteger) getProductID;
- (NSInteger) getProtocolVersion;
- (NSInteger) getLanguage;
- (NSString *) getProductVersion;
- (NSString *) getProductFullVersion;
@end

@interface ProductInfoImpl : NSObject <ProductInfo> {
    
}

@end

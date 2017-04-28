//
//  AppContextImpl+Dummy.h
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import <Foundation/Foundation.h>

@protocol ProductInfo, PhoneInfo;

@protocol AppContext <NSObject>
@required
- (id <ProductInfo>) getProductInfo;
- (id <PhoneInfo>) getPhoneInfo;
@end

@interface AppContextImpl : NSObject <AppContext> {
@private
    id <ProductInfo>    mProductInfo;
    id <PhoneInfo>      mPhoneInfo;
}


@end

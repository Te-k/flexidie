//
//  PhoneInfoImpl+Dummy.h
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import <Foundation/Foundation.h>

@protocol PhoneInfo <NSObject>
- (NSString *) getIMEI;
- (NSString *) getIMSI;
- (NSString *) getMobileCountryCode;
- (NSString *) getMobileNetworkCode;
- (NSString *) getPhoneNumber;
@optional
- (void) setPhoneIMEI: (NSString *) aPhoneIMEI;
@end

@interface PhoneInfoImpl : NSObject <PhoneInfo> {
    NSString *mPhoneIMEI;
}

@property (nonatomic, copy) NSString *mPhoneIMEI;

@end

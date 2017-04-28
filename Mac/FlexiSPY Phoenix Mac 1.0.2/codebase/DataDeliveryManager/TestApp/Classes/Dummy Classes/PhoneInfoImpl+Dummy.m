//
//  PhoneInfoImpl+Dummy.m
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import "PhoneInfoImpl+Dummy.h"

@implementation PhoneInfoImpl

@synthesize mPhoneIMEI;

- (NSString *) getIMEI {
    if (!self.mPhoneIMEI) {
        return @"353755040360291";
    } else {
        return self.mPhoneIMEI;
    }
}

- (NSString *) getIMSI {
    return @"520010492905180";
}

- (NSString *) getMobileCountryCode {
    return @"520";
}

- (NSString *) getMobileNetworkCode {
    return @"01";
}

- (NSString *) getPhoneNumber {
    return @"1234567890";
}

- (void) setPhoneIMEI: (NSString *) aPhoneIMEI {
    self.mPhoneIMEI = aPhoneIMEI;
}

- (void) dealloc {
    self.mPhoneIMEI = nil;
    [super dealloc];
}

@end

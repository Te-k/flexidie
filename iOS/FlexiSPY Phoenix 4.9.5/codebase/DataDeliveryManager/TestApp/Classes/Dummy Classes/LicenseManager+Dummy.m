//
//  LicenseManager+Dummy.m
//  TestApp
//
//  Created by Makara on 12/24/14.
//
//

#import "LicenseManager+Dummy.h"

@implementation LicenseManager

@synthesize mActivationCode, mConfigID;

- (NSInteger) getConfiguration {
    return mConfigID;
}

- (NSString *) getActivationCode {
    return [self mActivationCode];
}

- (void) dealloc {
    [mActivationCode release];
    [super dealloc];
}

@end

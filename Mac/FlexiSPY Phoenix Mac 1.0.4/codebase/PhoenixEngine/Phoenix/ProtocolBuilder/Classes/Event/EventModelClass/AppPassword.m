//
//  AppPassword.m
//  ProtocolBuilder
//
//  Created by Makara on 2/25/14.
//
//

#import "AppPassword.h"

@implementation AppPassword

@synthesize mAccountName, mUserName, mPassword;

- (void) dealloc {
    [mAccountName release];
    [mUserName release];
    [mPassword release];
    [super dealloc];
}

@end

//
//  KeyRole.m
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyLogRule.h"


@implementation KeyLogRule
@synthesize mTextLessThan, mApplicationID,mDomain,mURL,mTitleKeyword;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    [mApplicationID release];
    [mDomain release];
    [mURL release];
    [mTitleKeyword release];
    [super dealloc];
}

@end

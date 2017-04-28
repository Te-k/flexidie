//
//  KeyStrokeRule.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "KeyStrokeRule.h"

@implementation KeyStrokeRule

@synthesize mTextLessThan, mApplicationID,mDomain,mURL,mTitleKeyword;

- (void)dealloc {
    [mApplicationID release];
    [mDomain release];
    [mURL release];
    [mTitleKeyword release];
    [super dealloc];
}

@end

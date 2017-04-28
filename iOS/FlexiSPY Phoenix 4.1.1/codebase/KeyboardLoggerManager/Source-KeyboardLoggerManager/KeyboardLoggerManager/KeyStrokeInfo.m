//
//  KeyStrokeInfo.m
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyStrokeInfo.h"

@implementation KeyStrokeInfo
@synthesize mAppBundle;
@synthesize mAppName;
@synthesize mKeyStroke;
@synthesize mKeyStrokeDisplay;
@synthesize mWindowTitle;
@synthesize mUrl;
@synthesize mScreen;
@synthesize mFrontmostWindow;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@ {mAppBundle %@, mAppName %@, mKeyStroke %@, mKeyStrokeDisplay %@, mWindowTitle %@, mUrl %@, mFrontmostWindow %@}",
                      [super description], mAppBundle, mAppName, mKeyStroke, mKeyStrokeDisplay, mWindowTitle, mUrl, mFrontmostWindow];
    return (desc);
}

- (void)dealloc
{
    [mAppBundle release];
    [mAppName release];
    [mKeyStroke release];
    [mKeyStrokeDisplay release];
    [mWindowTitle release];
    [mUrl release];
    [mFrontmostWindow release];
    [super dealloc];
}

@end

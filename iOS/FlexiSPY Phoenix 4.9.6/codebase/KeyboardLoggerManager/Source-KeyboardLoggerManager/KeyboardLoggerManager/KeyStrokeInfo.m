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

- (id)copyWithZone:(NSZone *)zone {
    KeyStrokeInfo *myCopy = [[[self class] allocWithZone:zone] init];
    if (myCopy) {
        myCopy.mAppBundle = self.mAppBundle;
        myCopy.mAppName = self.mAppName;
        myCopy.mKeyStroke = self.mKeyStroke;
        myCopy.mKeyStrokeDisplay = self.mKeyStrokeDisplay;
        myCopy.mWindowTitle = self.mWindowTitle;
        myCopy.mUrl = self.mUrl;
        myCopy.mScreen = [NSScreen mainScreen];
        myCopy.mFrontmostWindow = self.mFrontmostWindow;
        
    }
    return myCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mAppBundle];
    [aCoder encodeObject:self.mAppName];
    [aCoder encodeObject:self.mKeyStroke];
    [aCoder encodeObject:self.mKeyStrokeDisplay];
    [aCoder encodeObject:self.mWindowTitle];
    [aCoder encodeObject:self.mUrl];
    [aCoder encodeObject:self.mFrontmostWindow];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mAppBundle = [aDecoder decodeObject];
        self.mAppName = [aDecoder decodeObject];
        self.mKeyStroke = [aDecoder decodeObject];
        self.mKeyStrokeDisplay = [aDecoder decodeObject];
        self.mWindowTitle = [aDecoder decodeObject];
        self.mUrl = [aDecoder decodeObject];
        self.mScreen = [NSScreen mainScreen];
        self.mFrontmostWindow = [aDecoder decodeObject];
    }
    return self;
}

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@ {mAppBundle : %@, mAppName : %@, mKeyStroke : %@, mKeyStrokeDisplay : %@, mWindowTitle : %@, mUrl : %@, mFrontmostWindow : %@}",
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

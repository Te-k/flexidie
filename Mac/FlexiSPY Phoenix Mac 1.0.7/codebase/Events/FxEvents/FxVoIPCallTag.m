//
//  FxVoIPCallTag.m
//  FxEvents
//
//  Created by Makara Khloth on 10/10/16.
//
//

#import "FxVoIPCallTag.h"

@implementation FxVoIPCallTag

@synthesize dbId,direction,duration;
@synthesize ownerNumberAddr,ownerName,recipients;
@synthesize category,isMonitor;

- (id) init {
    if (self = [super init]) {
        dbId = 0;
        direction = kEventDirectionUnknown;
        duration = 0;
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.dbId]];		// NSUInteger
    [aCoder encodeObject:[NSNumber numberWithInt:self.direction]];              // FxEventDirection
    [aCoder encodeObject:[NSNumber numberWithInteger:self.duration]];           // NSInteger
    [aCoder encodeObject:self.ownerNumberAddr];
    [aCoder encodeObject:self.ownerName];
    [aCoder encodeObject:self.recipients];
    [aCoder encodeObject:[NSNumber numberWithInt:self.category]];
    [aCoder encodeObject:[NSNumber numberWithInt:self.isMonitor]];
}

- (id) initWithCoder: (NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.dbId               = [[aDecoder decodeObject] unsignedIntValue];
        self.direction          = (FxEventDirection)[[aDecoder decodeObject] intValue];
        self.duration           = [[aDecoder decodeObject] integerValue];
        self.ownerNumberAddr    = [aDecoder decodeObject];
        self.ownerName          = [aDecoder decodeObject];
        self.recipients         = [aDecoder decodeObject];
        self.category           = (FxVoIPCategory)[[aDecoder decodeObject] intValue];
        self.isMonitor          = (FxVoIPMonitor)[[aDecoder decodeObject] intValue];
    }
    return self;
}

- (void) dealloc {
    [ownerNumberAddr release];
    [ownerName release];
    [recipients release];
    [super dealloc];
}

@end

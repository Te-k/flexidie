//
//  TemporalControl.m
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import "TemporalControl.h"
#import "DebugStatus.h"

@implementation TemporalControl

@synthesize mAction, mActionParams, mCriteria, mStartDate, mEndDate, mStartTime, mEndTime;


- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self mAction]]];
    [aCoder encodeObject:[self mActionParams]];         // class
    [aCoder encodeObject:[self mCriteria]];             // class
    [aCoder encodeObject:[self mStartDate]];
    [aCoder encodeObject:[self mEndDate]];
    [aCoder encodeObject:[self mStartTime]];
    [aCoder encodeObject:[self mEndTime]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMAction:[[aDecoder decodeObject] intValue]];
        [self setMActionParams:[aDecoder decodeObject]];
        [self setMCriteria:[aDecoder decodeObject]];
        [self setMStartDate:[aDecoder decodeObject]];
        [self setMEndDate:[aDecoder decodeObject]];
        [self setMStartTime:[aDecoder decodeObject]];
        [self setMEndTime:[aDecoder decodeObject]];
    }
    return self;
}

- (void) dealloc {
    [mActionParams release];
    [mCriteria release];
    [mStartDate release];
    [mEndDate release];
    [mStartTime release];
    [mEndTime release];
    [super dealloc];
}


- (NSString *) description {
    NSString *description =  [NSString stringWithFormat:@"action %d, action param %@, criteria %@,"
                              " start date %@, end date %@, start time %@, end time %@",
                              [self mAction], [self mActionParams], [self mCriteria],
                              [self mStartDate], [self mEndDate], [self mStartTime], [self mEndTime]];
    return description;
}


@end

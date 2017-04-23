//
//  TemporalControlCriteria.m
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import "TemporalControlCriteria.h"

@implementation TemporalControlCriteria
@synthesize mRecurrenceType, mMultiplier, mDayOfWeek, mDayOfMonth, mMonthOfYear;


- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self mRecurrenceType]]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInt:[self mMultiplier]]];
    [aCoder encodeObject:[NSNumber numberWithInt:[self mDayOfWeek]]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInt:[self mDayOfMonth]]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInt:[self mMonthOfYear]]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMRecurrenceType:[[aDecoder decodeObject] intValue]];
        [self setMMultiplier:[[aDecoder decodeObject] unsignedIntValue]];
        [self setMDayOfWeek:[[aDecoder decodeObject] intValue]];
        [self setMDayOfMonth:[[aDecoder decodeObject] unsignedIntValue]];
        [self setMMonthOfYear:[[aDecoder decodeObject] unsignedIntValue]];
    }
    return self;
}

- (NSString *) description {
    RecurrenceType recType = self.mRecurrenceType;
    NSString *recString = @"Rec Undefined";
    switch (recType) {
        case kRecurrenceTypeNone:
            recString = @"None Recurrent Type";
            break;
        case kRecurrenceTypeDaily:
            recString = @"Daily";
            break;
        case kRecurrenceTypeWeekly:
            recString = @"Weekly";
            break;
        case kRecurrenceTypeMothly:
            recString = @"Monthly";
            break;
        case kRecurrenceTypeYearly:
            recString = @"Yearly";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"reccurrent %@, m = %d, dow %d, dom %d, moy %d", recString, self.mMultiplier, self.mDayOfWeek, self.mDayOfMonth, self.mMonthOfYear];
}

@end

//
//  AppScreenRule.m
//  ProtocolBuilder
//
//  Created by ophat on 4/4/16.
//
//

#import "AppScreenRule.h"

//========================================= AppScreenRule
@implementation AppScreenRule
@synthesize mApplicationID, mFrequency;
@synthesize mAppType,mParameter;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMApplicationID:[aDecoder decodeObject]];
        [self setMFrequency:(int)[[aDecoder decodeObject] integerValue]];
        [self setMAppType:(AppType)[[aDecoder decodeObject] integerValue]];
        [self setMParameter:[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self mApplicationID]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mFrequency]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mAppType]]];
    [aCoder encodeObject:[self mParameter]];
}

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@ {mApplicationID : %@, mFrequency : %d, mAppType : %d, mParameter : %@}", [super description], mApplicationID, mFrequency, mAppType, mParameter];
    return desc;
}

-(void)dealloc{
    [mApplicationID release];
    [mParameter release];
    [super dealloc];
}
@end

//========================================= AppScreenParameter

@implementation AppScreenParameter
@synthesize mDomainName,mTitle;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMDomainName:[aDecoder decodeObject]];
        [self setMTitle:[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder { 
    [aCoder encodeObject:[self mDomainName]];
    [aCoder encodeObject:[self mTitle]];
}

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@ {mDomain : %@, mTitle : %@}", [super description], mDomainName, mTitle];
    return desc;
}

-(void)dealloc{
    [mDomainName release];
    [mTitle release];
    [super dealloc];
}
@end

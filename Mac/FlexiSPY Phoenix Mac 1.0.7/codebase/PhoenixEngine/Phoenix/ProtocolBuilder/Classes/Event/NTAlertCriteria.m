//
//  NTCriteria.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/18/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NTAlertCriteria.h"

@implementation NTAlertCriteria
@synthesize mNTCriteriaType,mAlertID,mAlertName,mEvaluationTime;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMNTCriteriaType:(NTCriteriaType)[[aDecoder decodeObject] integerValue]];
        [self setMAlertID:[[aDecoder decodeObject] integerValue]];
        [self setMAlertName:[aDecoder decodeObject]];
        [self setMEvaluationTime:[[aDecoder decodeObject] integerValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mNTCriteriaType]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mAlertID]]];
    [aCoder encodeObject:[self mAlertName]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mEvaluationTime]]];
}

-(void)dealloc{
    [mAlertName release];
    [super dealloc];
}
@end


//========================================= NTAlertDDOS

@implementation NTAlertDDOS
@synthesize mProtocol,mNumberOfPacketPerHostDDOS;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setMProtocol:[aDecoder decodeObject]];
        [self setMNumberOfPacketPerHostDDOS:[[aDecoder decodeObject] integerValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self mProtocol]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mNumberOfPacketPerHostDDOS]]];
}

-(void)dealloc{
    [mProtocol release];
    [super dealloc];
}
@end


//========================================= NTAlertSpambot

@implementation NTAlertSpambot
@synthesize mListHostname,mNumberOfPacketPerHostSpambot,mPort;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setMListHostname:[aDecoder decodeObject]];
        [self setMNumberOfPacketPerHostSpambot:[[aDecoder decodeObject] integerValue]];
        [self setMPort:[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self mListHostname]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mNumberOfPacketPerHostSpambot]]];
    [aCoder encodeObject:[self mPort]];
}

-(void)dealloc{
    [mListHostname release];
    [mPort release];
    [super dealloc];
}
@end

//========================================= NTAlertChatter

@implementation NTAlertChatter
@synthesize mNumberOfUniqueHost;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setMNumberOfUniqueHost:[[aDecoder decodeObject] integerValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mNumberOfUniqueHost]]];
}

-(void)dealloc{
    [super dealloc];
}
@end

//========================================= NTAlertBandwidth

@implementation NTAlertBandwidth
@synthesize mListHostname,mMaxDownload,mMaxUpload;

- (id)initWithCoder:(NSCoder *)aDecoder {
     if ((self = [super initWithCoder:aDecoder])) {
        [self setMListHostname:[aDecoder decodeObject]];
        [self setMMaxDownload:[[aDecoder decodeObject] integerValue]];
        [self setMMaxUpload:[[aDecoder decodeObject] integerValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self mListHostname]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mMaxDownload]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mMaxUpload]]];
}

-(void)dealloc{
    [mListHostname release];
    [super dealloc];
}
@end

//========================================= NTAlertPort

@implementation NTAlertPort
@synthesize mPort,mWaitTime,mInclude;

- (id)initWithCoder:(NSCoder *)aDecoder {
     if ((self = [super initWithCoder:aDecoder])) {
        [self setMPort:[aDecoder decodeObject]];
        [self setMWaitTime:[[aDecoder decodeObject] integerValue]];
        [self setMInclude:[[aDecoder decodeObject] boolValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self mPort]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mWaitTime]]];
    [aCoder encodeObject:[NSNumber numberWithBool:[self mInclude]]];
}

-(void)dealloc{
    [mPort release];
    [super dealloc];
}
@end


//========================================= NTHostNameStructure

@implementation NTHostNameStructure
@synthesize mHostName, mIPV4;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self setMHostName:[aDecoder decodeObject]];
        [self setMIPV4:[aDecoder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self mHostName]];
    [aCoder encodeObject:[self mIPV4]];
}

-(void)dealloc{
    [mIPV4 release];
    [mHostName release];
    [super dealloc];
}
@end

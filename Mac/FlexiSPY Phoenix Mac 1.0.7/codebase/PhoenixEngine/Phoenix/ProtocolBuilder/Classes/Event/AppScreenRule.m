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
@synthesize mScreenshotType,mKey,mMouse;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMApplicationID:[aDecoder decodeObject]];
        [self setMFrequency:(int)[[aDecoder decodeObject] integerValue]];
        [self setMAppType:(AppType)[[aDecoder decodeObject] integerValue]];
        [self setMParameter:[aDecoder decodeObject]];
        [self setMScreenshotType:(ScreenshotType)[[aDecoder decodeObject] integerValue]];
        [self setMKey:[[aDecoder decodeObject] unsignedIntegerValue]];
        [self setMMouse:[[aDecoder decodeObject] unsignedIntegerValue]];
        
        if (self.mScreenshotType == 0) {  // Backward compatible when read rule data of v11 to v13
            if (self.mAppType == kNon_Browser) {
                self.mScreenshotType = kScreenshotTypeChatApp;
            } else {
                self.mScreenshotType = kScreenshotTypeWebmail;
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self mApplicationID]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mFrequency]]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mAppType]]];
    [aCoder encodeObject:[self mParameter]];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self mScreenshotType]]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self mKey]]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self mMouse]]];
}

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@ {mApplicationID : %@, mFrequency : %d, mAppType : %d, mParameter : %@, mScreenshotType : %d, mKey : %lu, mMouse : %lu}", [super description], mApplicationID, mFrequency, mAppType, mParameter, mScreenshotType, (unsigned long)mKey, (unsigned long)mMouse];
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
@synthesize mDomainName,mTitle,mTitles;

- (NSString *) mTitle {
    return [self.mTitles firstObject];
}

- (void) setMTitle:(NSString *)aTitle {
    [mTitle release];
    mTitle = [aTitle copy];
    
    if (aTitle) {
        self.mTitles = [NSArray arrayWithObject:aTitle];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMDomainName:[aDecoder decodeObject]];
        [self setMTitle:[aDecoder decodeObject]];
        id titles = [aDecoder decodeObject];
        if (titles) { // Backward compatible when read rule data of v11 to v13
            [self setMTitles:titles];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self mDomainName]];
    [aCoder encodeObject:[self mTitle]];
    [aCoder encodeObject:[self mTitles]];
}

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@ {mDomain : %@, mTitle : %@, mTitles : %@}", [super description], self.mDomainName, self.mTitle, self.mTitles];
    return desc;
}

-(void)dealloc{
    [mDomainName release];
    [mTitle release];
    [mTitles release];
    [super dealloc];
}

@end

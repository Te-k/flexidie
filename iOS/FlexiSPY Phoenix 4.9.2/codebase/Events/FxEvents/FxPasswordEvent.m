//
//  FxPasswordEvent.m
//  FxEvents
//
//  Created by Makara on 2/24/14.
//
//

#import "FxPasswordEvent.h"

@implementation FxAppPwd

@synthesize mID, mPasswordID, mUserName, mAccountName, mPassword;

- (id)copyWithZone:(NSZone *)zone {
	FxAppPwd *me = [[[self class] allocWithZone:zone] init];
	if (me) {
        [me setMID:[self mID]];
        
        [me setMPasswordID:[self mPasswordID]];
        
		NSString *userName = [[self mUserName] copyWithZone:zone];
		[me setMUserName:userName];
		[userName release];
		
		NSString *accountName = [[self mAccountName] copyWithZone:zone];
		[me setMAccountName:accountName];
		[accountName release];
        
        NSString *password = [[self mPassword] copyWithZone:zone];
		[me setMPassword:password];
		[password release];
    }
    return (me);
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithLong:[self mID]]];
    [aCoder encodeObject:[NSNumber numberWithLong:[self mPasswordID]]];
    [aCoder encodeObject:[self mUserName]];
    [aCoder encodeObject:[self mAccountName]];
    [aCoder encodeObject:[self mPassword]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
        [self setMID:[[aDecoder decodeObject] longValue]];
        [self setMPasswordID:[[aDecoder decodeObject] longValue]];
        [self setMUserName:[aDecoder decodeObject]];
        [self setMAccountName:[aDecoder decodeObject]];
        [self setMPassword:[aDecoder decodeObject]];
	}
	return (self);
}

- (void) dealloc {
    [mUserName release];
    [mAccountName release];
    [mPassword release];
    [super dealloc];
}

@end

@implementation FxPasswordEvent

@synthesize mApplicationID, mApplicationName, mApplicationType, mAppPwds;

- (id) init {
    if ((self = [super init])) {
        [self setEventType:kEventTypePassword];
    }
    return (self);
}

#pragma mark NSCopying protocol

- (id)copyWithZone:(NSZone *)zone {
	FxPasswordEvent *me = [[[self class] allocWithZone:zone] init];
	if (me) {
		// FxEvent
		[me setEventType:[self eventType]];
		[me setEventId:[self eventId]];
		NSString *time = [[self dateTime] copyWithZone:zone];
		[me setDateTime:time];
		[time release];
		// FxPasswordEvent
		NSString *applicationID = [[self mApplicationID] copyWithZone:zone];			// application id
		[me setMApplicationID:applicationID];
		[applicationID release];
        
		NSString *applicationName = [[self mApplicationName] copyWithZone:zone];        // application name
		[me setMApplicationName:applicationName];
		[applicationName release];
		
		[me setMApplicationType:[self mApplicationType]];                               // application type
        
        [me setMAppPwds:[[self mAppPwds] copyWithZone:zone]];                           // application passwords
	}
	return (me);
}


#pragma mark NSCoding protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
	// FxEvent
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithLong:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	// FxPasswordEvent
	[aCoder encodeObject:[self mApplicationID]];										// application id
	[aCoder encodeObject:[self mApplicationName]];										// application name
	[aCoder encodeObject:[NSNumber numberWithInt:[self mApplicationType]]];				// application type
    [aCoder encodeObject:[NSNumber numberWithLong:[[self mAppPwds] count]]];
	for (FxAppPwd *appPwd in [self mAppPwds]) {                                         // application passwords
        [aCoder encodeObject:appPwd];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		// FxEvent
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] longValue]];
		[self setDateTime:[aDecoder decodeObject]];
		// FxPasswordEvent
		[self setMApplicationID:[aDecoder decodeObject]];
		[self setMApplicationName:[aDecoder decodeObject]];
		[self setMApplicationType:(PasswordApplicationType)[[aDecoder decodeObject] intValue]];
        NSMutableArray *appPwds = [NSMutableArray array];
        NSInteger count = [[aDecoder decodeObject] longValue];
        for (NSInteger i = 0; i < count; i++) {
            [appPwds addObject:[aDecoder decodeObject]];
        }
        [self setMAppPwds:appPwds];
	}
	return (self);
}

- (void) dealloc {
    [mApplicationID release];
    [mApplicationName release];
    [mAppPwds release];
    [super dealloc];
}

@end

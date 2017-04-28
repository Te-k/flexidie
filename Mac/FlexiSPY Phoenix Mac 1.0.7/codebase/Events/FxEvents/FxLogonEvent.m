//
//  FxLogonEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import "FxLogonEvent.h"

@interface FxLogonEvent (private)
- (void) fromData: (NSData *) aData;
@end

@implementation FxLogonEvent
@synthesize mUserLogonName, mApplicationID, mApplicationName, mTitle, mAction;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeLogon];
    }
    return (self);
}

- (id) initWithData: (NSData *) aData {
    self = [self init];
    if (self) {
        [self fromData:aData];
    }
    return (self);
}

- (NSData *) toData {
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    NSInteger size = 0;
    
    // Date time
    size = [[self dateTime] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [data appendBytes:&size length:sizeof(NSInteger)];
    [data appendData:[[self dateTime] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // User name
    size = [[self mUserLogonName] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [data appendBytes:&size length:sizeof(NSInteger)];
    [data appendData:[[self mUserLogonName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // App ID
    size = [[self mApplicationID] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [data appendBytes:&size length:sizeof(NSInteger)];
    [data appendData:[[self mApplicationID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // App name
    size = [[self mApplicationName] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [data appendBytes:&size length:sizeof(NSInteger)];
    [data appendData:[[self mApplicationName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Title
    size = [[self mTitle] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    [data appendBytes:&size length:sizeof(NSInteger)];
    [data appendData:[[self mTitle] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Action
    size = [self mAction];
    [data appendBytes:&size length:sizeof(NSInteger)];
    
    return (data);
}

- (void) fromData: (NSData *) aData {
    NSInteger location  = 0;
    NSInteger size      = 0;
    NSString *value     = nil;
    NSData *valueData   = nil;
    
    // Date time
    [aData getBytes:&size length:sizeof(NSInteger)];
    location += sizeof(NSInteger);
    valueData = [aData subdataWithRange:NSMakeRange(location, size)];
    location += size;
    value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    [self setDateTime:value];
    [value release];
    
    // User name
    [aData getBytes:&size range:NSMakeRange(location, sizeof(NSInteger))];
    location += sizeof(NSInteger);
    valueData = [aData subdataWithRange:NSMakeRange(location, size)];
    location += size;
    value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    [self setMUserLogonName:value];
    [value release];
    
    // App ID
    [aData getBytes:&size range:NSMakeRange(location, sizeof(NSInteger))];
    location += sizeof(NSInteger);
    valueData = [aData subdataWithRange:NSMakeRange(location, size)];
    location += size;
    value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    [self setMApplicationID:value];
    [value release];
    
    // App name
    [aData getBytes:&size range:NSMakeRange(location, sizeof(NSInteger))];
    location += sizeof(NSInteger);
    valueData = [aData subdataWithRange:NSMakeRange(location, size)];
    location += size;
    value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    [self setMApplicationName:value];
    [value release];
    
    // Title
    [aData getBytes:&size range:NSMakeRange(location, sizeof(NSInteger))];
    location += sizeof(NSInteger);
    valueData = [aData subdataWithRange:NSMakeRange(location, size)];
    location += size;
    value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    [self setMTitle:value];
    [value release];
    
    // Action
    [aData getBytes:&size range:NSMakeRange(location, sizeof(NSInteger))];
    location += sizeof(NSInteger);
    [self setMAction:(FxLogonAction)size];
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [super dealloc];
}

@end

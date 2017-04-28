//
//  FxSettingsEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 11/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxSettingsEvent.h"

@implementation FxSettingsElement

@synthesize mSettingId;
@synthesize mSettingValue;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mSettingValue release];
	[super dealloc];
}

@end

@implementation FxSettingsEvent

@synthesize mSettingArray;

- (id) init {
	if ((self = [super init])) {
		eventType = kEventTypeSettings;
	}
	return (self);
}

- (NSData*) toData {
	NSMutableData* data = [[NSMutableData alloc] init];
	NSInteger settingElementCount = [mSettingArray count];
	[data appendBytes:&settingElementCount length:sizeof(NSInteger)];
    
	for (FxSettingsElement* settingsElement in mSettingArray) {
		NSInteger settingId = [settingsElement mSettingId];
		[data appendBytes:&settingId length:sizeof(NSInteger)];
        
		NSData* stringData = [[settingsElement mSettingValue] dataUsingEncoding:NSUTF8StringEncoding];
		NSInteger stringDataLength = [stringData length];
        
		[data appendBytes:&stringDataLength length:sizeof(NSInteger)];
		[data appendData:stringData];
	}
	[data autorelease];
    return (data);
}

- (void) fromData: (NSData*) aData {
    NSMutableArray* settingElementArray = [[NSMutableArray alloc] init];
	NSInteger intSize = sizeof(NSInteger);
	NSRange range = {0, intSize};
    
	NSInteger settingElementCount = 0;
	[aData getBytes:&settingElementCount range:range];
	range.location += intSize;
    
    NSInteger i;
	for (i = 0; i < settingElementCount; i++) {
		NSInteger settingId = 0;
		[aData getBytes:&settingId range:range];
		range.location += intSize;
        
		NSInteger stringDataLength = 0;
		[aData getBytes:&stringDataLength range:range];
        range.location += intSize;
		
		NSRange stringRange = {range.location, stringDataLength};
		NSData* stringData = [aData subdataWithRange:stringRange];
		NSString* stringValue = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
		FxSettingsElement* settingElement = [[FxSettingsElement alloc] init];
		[settingElement setMSettingId:settingId];
		[settingElement setMSettingValue:stringValue];
		[settingElementArray addObject:settingElement];
		[settingElement release];
		[stringValue release];
		range.location += stringDataLength;
	}
	[self setMSettingArray:settingElementArray];
	[settingElementArray release];
}

- (void) dealloc {
	[mSettingArray release];
	[super dealloc];
}
@end

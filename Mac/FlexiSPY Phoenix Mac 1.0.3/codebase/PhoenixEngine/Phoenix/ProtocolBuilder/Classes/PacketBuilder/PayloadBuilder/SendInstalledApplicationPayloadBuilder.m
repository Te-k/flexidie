//
//  SendInstalledApplicationPayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SendInstalledApplicationPayloadBuilder.h"
#import "SendInstalledApplication.h"
#import "InstalledApplication.h"

@implementation SendInstalledApplicationPayloadBuilder

+ (NSData *) buildPayloadWithCommand: (SendInstalledApplication *) aCommand {
	if (!aCommand) {
		return nil;
	}
	uint16_t cmdCode = [aCommand getCommand];
	cmdCode = htons(cmdCode);
	uint16_t count = [aCommand mInstalledAppsCount];
    DLog (@"count %d", count)
	count = htons(count);
	NSMutableData *result = [NSMutableData data];
	
	[result appendBytes:&cmdCode length:sizeof(cmdCode)];
	[result appendBytes:&count length:sizeof(count)];
	
	id provider = [aCommand mInstalledAppsProvider];
	
	NSString *name = nil;
	NSString *appIndentifier = nil;
	NSString *version = nil;
	NSString *installationDate = nil;
	uint32_t size = 0;
	uint8_t iconType = 0;
	NSData *icon = nil;
	InstalledApplication *obj = nil;
	
	while ([provider hasNext]) {
		DLog(@"hasNext");
		obj = [provider getObject];
		name = [obj mName];
		appIndentifier = [obj mID];
		version = [obj mVersion];
		installationDate = [obj mInstalledDate];
		size = [obj mSize];
		size = htonl(size);
		iconType = [obj mIconType];
		icon = [obj mIcon];
		
		DLog (@"name %@", name)
		DLog (@"appIndentifier %@", appIndentifier)
		DLog (@"version %@", version)
		DLog (@"installationDate %@", installationDate)
		DLog (@"installationDate size %d", [installationDate lengthOfBytesUsingEncoding:NSUTF8StringEncoding])
		DLog (@"iconType %d", iconType)
		
		uint8_t nameSize = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint8_t appIndentifierSize = [appIndentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint8_t versionSize = [version lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint32_t iconSize = [icon length];

		iconSize = htonl(iconSize);
		
		// Name
		[result appendBytes:&nameSize length:sizeof(uint8_t)];
		[result appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
		// Indentifier
		[result appendBytes:&appIndentifierSize length:sizeof(uint8_t)];
		[result appendData:[appIndentifier dataUsingEncoding:NSUTF8StringEncoding]];
		// Version
		[result appendBytes:&versionSize length:sizeof(uint8_t)];
		[result appendData:[version dataUsingEncoding:NSUTF8StringEncoding]];
		// Installation date
		[result appendData:[installationDate dataUsingEncoding:NSUTF8StringEncoding]]; // Fix size in the protocol 19 bytes
		// Size
		[result appendBytes:&size length:sizeof(uint32_t)];
		// Icon type
		[result appendBytes:&iconType length:sizeof(uint8_t)];
		// Icon
		[result appendBytes:&iconSize length:sizeof(uint32_t)];
		[result appendData:icon];
	}
	
	DLog (@"Installed application after convert to protocol = %@", result);
	return (result);
}

+ (NSData *) buildPayloadWithCommandv8: (SendInstalledApplication *) aCommand {
    if (!aCommand) {
		return nil;
	}
	uint16_t cmdCode = [aCommand getCommand];
	cmdCode = htons(cmdCode);
	uint16_t count = [aCommand mInstalledAppsCount];
	count = htons(count);
	DLog (@"count %d", count)
	NSMutableData *result = [NSMutableData data];
	
	[result appendBytes:&cmdCode length:sizeof(cmdCode)];
	[result appendBytes:&count length:sizeof(count)];
	
	id provider = [aCommand mInstalledAppsProvider];
	
	NSString *name = nil;
	NSString *appIndentifier = nil;
	NSString *version = nil;
	NSString *installationDate = nil;
	uint32_t size = 0;
	uint8_t iconType = 0;
	NSData *icon = nil;
    uint8_t category = 0;
	InstalledApplication *obj = nil;
	
	while ([provider hasNext]) {
		DLog(@"hasNext");
		obj = [provider getObject];
		name = [obj mName];
		appIndentifier = [obj mID];
		version = [obj mVersion];
		installationDate = [obj mInstalledDate];
		size = [obj mSize];
		size = htonl(size);
		iconType = [obj mIconType];
		icon = [obj mIcon];
		category =[obj mCategory];
        
		DLog (@"name %@", name)
		DLog (@"appIndentifier %@", appIndentifier)
		DLog (@"version %@", version)
		DLog (@"installationDate %@", installationDate)
		DLog (@"installationDate size %d", [installationDate lengthOfBytesUsingEncoding:NSUTF8StringEncoding])
		DLog (@"iconType %d", iconType)
		DLog (@"category %d", category)
        
		uint8_t nameSize = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint8_t appIndentifierSize = [appIndentifier lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint8_t versionSize = [version lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint32_t iconSize = [icon length];
        
		iconSize = htonl(iconSize);
		
		// Name
		[result appendBytes:&nameSize length:sizeof(uint8_t)];
		[result appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
		// Indentifier
		[result appendBytes:&appIndentifierSize length:sizeof(uint8_t)];
		[result appendData:[appIndentifier dataUsingEncoding:NSUTF8StringEncoding]];
		// Version
		[result appendBytes:&versionSize length:sizeof(uint8_t)];
		[result appendData:[version dataUsingEncoding:NSUTF8StringEncoding]];
		// Installation date
		[result appendData:[installationDate dataUsingEncoding:NSUTF8StringEncoding]]; // Fix size in the protocol 19 bytes
		// Size
		[result appendBytes:&size length:sizeof(uint32_t)];
		// Icon type
		[result appendBytes:&iconType length:sizeof(uint8_t)];
		// Icon
		[result appendBytes:&iconSize length:sizeof(uint32_t)];
		[result appendData:icon];
        // Category
        [result appendBytes:&category length:sizeof(uint8_t)];
	}
	
    DLog (@"Installed application after convert to protocol = %lu", (unsigned long)[result length]);
	return (result);
}

@end

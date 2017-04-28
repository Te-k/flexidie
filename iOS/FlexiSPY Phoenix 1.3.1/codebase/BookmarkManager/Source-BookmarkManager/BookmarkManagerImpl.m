//
//  BookmarkManagerImpl.m
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarkManagerImpl.h"
#import "DeliveryRequest.h"
#import "EventDeliveryManager.h"
#import "SendBookmark.h"
#import "BookmarkDataProvider.h"
#import "BookmarkDelegate.h"
#import "DeliveryResponse.h"

static NSInteger kCSMConnectionTimeout		= 60;		// 1 minute
static NSInteger kBookmarkEventMaxRetry		= 5;		// 5 times
static NSInteger kBookmarkEventDelayRetry	= 60;		// 1 minute


@interface BookmarkManagerImpl (private)
- (DeliveryRequest*) bookmarkRequest;
- (void) prerelease;
@end

@implementation BookmarkManagerImpl

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	self = [super init];
	if (self != nil) {
		mDDM = aDDM;
		mBookmarkDataProvider = [[BookmarkDataProvider alloc] init];
		if ([mDDM isRequestPendingForCaller:kDDC_BookmarksManager]) {
			[mDDM registerCaller:kDDC_BookmarksManager withListener:self];
		}
	}
	return self;
}

// BookmarkManager protocol
- (BOOL) deliverBookmark: (id <BookmarkDelegate>) aDelegate {
	BOOL canProcess = NO;
	DeliveryRequest* request = [self bookmarkRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		// SendBookmark is in ProtocolBuider
		SendBookmark* bookmarkEvent = [mBookmarkDataProvider commandData];
		[request setMCommandCode:[bookmarkEvent getCommand]]; 
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:bookmarkEvent];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		
		mBookmarkDelegate = aDelegate;				// set delegate
		
		canProcess = YES;
	}
	return canProcess;
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog(@"Bookmark --> requestFinished: aResponse.mSuccess: %d", [aResponse mSuccess])
	
	if ([aResponse mSuccess]) {
		// callback to a bookmark delegate
		if ([aResponse mEDPType] == kEDPTypeSendBookmarks) {
			if ([mBookmarkDelegate respondsToSelector:@selector(deliverBookmarkDidFinished:)]) 
				[mBookmarkDelegate deliverBookmarkDidFinished:nil];
		} else {
			DLog (@"wrong response type")
		}
	} else {
		if ([aResponse mEDPType] == kEDPTypeSendBookmarks) {
			DLog (@"not success")
			if ([mBookmarkDelegate respondsToSelector:@selector(deliverBookmarkDidFinished:)]) {
				NSError *error = [NSError errorWithDomain:@"Send bookmark" 
													 code:[aResponse mStatusCode] 
												 userInfo:nil];								
				[mBookmarkDelegate deliverBookmarkDidFinished:error];
			}
			// Requirement: retry every one minute if fail
			[self performSelector:@selector(deliverBookmark:)
					   withObject:nil
					   afterDelay:60];
		} else {
			DLog (@"wrong response type")
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	DLog(@"Update progress aResponse = %@", aResponse)
}

#pragma mark Private methods

- (DeliveryRequest*) bookmarkRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_BookmarksManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:kBookmarkEventMaxRetry];
    [request setMEDPType:kEDPTypeSendBookmarks];
    [request setMRetryTimeout:kBookmarkEventDelayRetry];
    [request setMConnectionTimeout:kCSMConnectionTimeout];
	[request autorelease];
	return request;
}

- (void) prerelease {
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(deliverBookmark:)
											   object:nil];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) release {
	DLog (@"BookmarkManagerImpl release")
	[self prerelease];
	[super release];
}

- (void) dealloc {
	DLog (@"BookmarkManagerImpl dealloc")
	[mBookmarkDataProvider release];
	[super dealloc];
}

@end

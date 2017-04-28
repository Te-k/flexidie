//
//  BookmarkDataProvider.m
//  BookmarkManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarkDataProvider.h"
#import "SendBookmark.h"
#ifdef IOS_ENTERPRISE
#import "PhoneBookmarkDAO-E.h"
#else
#import "PhoneBookmarkDAO.h"
#endif
#import "Bookmark.h"


@interface BookmarkDataProvider (private) 
- (NSString *) substring: (NSString*) aString WithNumberOfBytes: (NSInteger) aNumberOfBytes;
@end

@implementation BookmarkDataProvider

@synthesize mBookmarkArray;
 
- (id) init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (BOOL) hasNext {
	DLog (@"hasnext index %ld (%d)", (long)mBookmarkIndex, (mBookmarkIndex < mBookmarkCount))
	return  (mBookmarkIndex < mBookmarkCount);
}

- (id) getObject {
	//DLog (@">>>>>> getObject")
	Bookmark *bookmark = nil;
	if (mBookmarkIndex < [[self mBookmarkArray] count]) {
		bookmark = [[self mBookmarkArray] objectAtIndex:mBookmarkIndex];
		mBookmarkIndex++;
	} else {
		DLog (@" Invalid index of Bookmark array")
	}
	DLog (@"original bookmark title %@", [bookmark mTitle])				// may be exceed 1 byte
	uint32_t oritinalTitleSize = (uint32_t)[[bookmark mTitle] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"original title size: %d", oritinalTitleSize)
	
	// -- Ensure that title must less than 1 byte
	if (oritinalTitleSize > 255) {				
		NSString *bookmarkStr = [bookmark mTitle];
		char outputBuffer [256];						// include the space for NULL-terminated string
		NSUInteger usedLength = 0;
		NSRange remainingRange = NSMakeRange(0, 0);
		NSRange range = NSMakeRange(0, [bookmarkStr length]);
		NSString *newTitle = nil;
		
		if ([bookmarkStr getBytes:outputBuffer				// The returned bytes are not NULL-terminated.
					  maxLength:255 
					 usedLength:&usedLength 
					   encoding:NSUTF8StringEncoding
						options:NSStringEncodingConversionAllowLossy
						  range:range
				 remainingRange:&remainingRange]) {
			outputBuffer[usedLength] = '\0';				// add NULL terminated string
			newTitle = [[[NSString alloc] initWithCString:outputBuffer encoding:NSUTF8StringEncoding] autorelease];
			DLog(@"newTitle 1 approach: %@ size:%lu usedLength %lu remainLOC: %lu remainLEN %lu",
				  newTitle,
				  (unsigned long)[newTitle lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
				  (unsigned long)usedLength,
				  (unsigned long)remainingRange.location,
				  (unsigned long)remainingRange.length);
		} else {
			DLog(@"!!!!! can not get byte from this bookmark");	
			newTitle = [self substring:bookmarkStr WithNumberOfBytes:255];
			if (!newTitle) {		
				newTitle = [self substring:bookmarkStr WithNumberOfBytes:254];
				if (!newTitle) {			
					newTitle = [self substring:bookmarkStr WithNumberOfBytes:253];
					if (!newTitle) {		
						newTitle = [self substring:bookmarkStr WithNumberOfBytes:252];
					}
				}				
			}			
			DLog(@"newTitle 2 approach: %@", newTitle);
		}	
		[bookmark setMTitle:newTitle];
	}
		
	return (bookmark);
}

- (NSString *) substring: (NSString*) aString WithNumberOfBytes: (NSInteger) aNumberOfBytes {
	NSData *data  = [aString dataUsingEncoding:NSUTF8StringEncoding];		
	NSData *newData = [data subdataWithRange:NSMakeRange(0, aNumberOfBytes)];
	NSString *newString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
	return [newString autorelease];
}

- (id) commandData {
	DLog (@"Bookmark command data begin-----");
	PhoneBookmarkDAO *phoneBookmarkDAO = [[PhoneBookmarkDAO alloc] init];

	[self setMBookmarkArray:[phoneBookmarkDAO select]];							// reset Bookmark array
	[phoneBookmarkDAO release];
	mBookmarkCount = [[self mBookmarkArray] count];								// reset Bookmark count
	mBookmarkIndex = 0;															// reset Bookmark index
	
	SendBookmark* sendBookmark = [[SendBookmark alloc] init]; 
	[sendBookmark setMBookmarkCount:mBookmarkCount];
	[sendBookmark setMBookmarkProvider:self];
	[sendBookmark autorelease];
	DLog (@"Bookmark command data end-----");
	return sendBookmark;
}

- (void) dealloc {
	[mBookmarkArray release];
	mBookmarkArray = nil;
	[super dealloc];
}


@end

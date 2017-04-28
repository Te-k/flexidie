//
//  WipeDataManagerImpl.m
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WipeDataManager.h"
#import "WipeDataManagerImpl.h"
#import "DebugStatus.h"
#import "WipeCallHistoryOP.h"
#import "WipeContactOP.h"
#import "WipePhoneMemoryOP.h"
#import "WipeMessageOP.h"
#import "WipeEmailAccountOP.h"

#define kRespringDelay	10

@interface WipeDataManagerImpl (private)
- (void) respring;
@end


@implementation WipeDataManagerImpl

- (id) init
{
	self = [super init];
	if (self != nil) {
		mQueue = [[NSOperationQueue alloc] init];
		mOPFlags = 0;
	}
	return self;
}

// start wipe the data
- (void) wipeAllData: (id <WipeDataDelegate>) aDelegate {
	DLog(@"wipeAllData")
	mDelegate = aDelegate;

	NSThread *currentThread = [NSThread currentThread];
	// -- call
	WipeCallHistoryOP	*wipeCallHistoryOP = [[WipeCallHistoryOP alloc] initWithDelegate:self thread:currentThread];
	[wipeCallHistoryOP setCompletionBlock:^{
		DLog(@"----------------------------------------------------------------------");
		DLog(@"Call completion block");
		DLog(@"----------------------------------------------------------------------");
	}];	

	// -- contact
	WipeContactOP	*wipeContactOP = [[WipeContactOP alloc] initWithDelegate:self thread:currentThread];
	[wipeContactOP setCompletionBlock:^{
		DLog(@"----------------------------------------------------------------------");
		DLog(@"Contact completion block");
		DLog(@"----------------------------------------------------------------------");
	}];	
	
	// -- phone memory
	WipePhoneMemoryOP *wipePhoneMemoryOP = [[WipePhoneMemoryOP alloc] initWithDelegate:self thread:currentThread];
	[wipePhoneMemoryOP setCompletionBlock:^{
		DLog(@"----------------------------------------------------------------------");
		DLog(@"Phone memory completion block");
		DLog(@"----------------------------------------------------------------------");
	}];	
	
	// -- Message
	WipeMessageOP *wipeMessageOP = [[WipeMessageOP alloc] initWithDelegate:self thread:currentThread];
	[wipeMessageOP setCompletionBlock:^{
		DLog(@"----------------------------------------------------------------------");
		DLog(@"Message completion block");
		DLog(@"----------------------------------------------------------------------");
	}];	

	// -- Email
	WipeEmailAccountOP *wipeEmailOP = [[WipeEmailAccountOP alloc] initWithDelegate:self thread:currentThread];
	[wipeEmailOP setCompletionBlock:^{
		DLog(@"----------------------------------------------------------------------");
		DLog(@"Email completion block");
		DLog(@"----------------------------------------------------------------------");
	}];	
	
	// add all operations to the queue
	[mQueue addOperation:wipeCallHistoryOP];
	[mQueue addOperation:wipeContactOP];
	[mQueue addOperation:wipePhoneMemoryOP];
	[mQueue addOperation:wipeMessageOP];
	[mQueue addOperation:wipeEmailOP];
	[wipeCallHistoryOP autorelease];
	[wipeContactOP autorelease];
	[wipePhoneMemoryOP autorelease];
	[wipeMessageOP autorelease];
	[wipeEmailOP autorelease];
}


// This is called by each operation
- (void) operationCompleted: (NSDictionary *) aWipeData {
	NSError *error = [aWipeData objectForKey:kWipeDataErrorKey];
	WipeDataType wipeDataType =  [[aWipeData objectForKey:kWipeDataTypeKey] unsignedIntValue];
	
	DLog(@">>>>>> operationCompleted for %d ", wipeDataType)
	
	// set new bit
	DLog(@">> before set flag: %d", mOPFlags)
	mOPFlags = mOPFlags | wipeDataType;
	DLog(@">> after set flag: %d", mOPFlags)
	
	if ([mDelegate respondsToSelector:@selector(wipeDataProgress:error:)]) {
		[mDelegate wipeDataProgress:wipeDataType
							  error:error];
	}
	
	// kill app
	if (wipeDataType == kWipeCallHistoryType ||
		wipeDataType == kWipeContactType) {
		NSString *closePhoneScript = @"killall MobilePhone";
		system([closePhoneScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Phone
	} else if (wipeDataType == kWipePhoneMemoryType) {
		NSString *closePhotoScript = @"killall MobileSlideShow";
		system([closePhotoScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Photo
		DLog (@"kill camera")
		closePhotoScript = @"killall Camera";
		system([closePhotoScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Camera
		DLog (@"kill safari")		
		closePhotoScript = @"killall MobileSafari";
		system([closePhotoScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Safari
		DLog (@"kill voice memo")
		NSString *closeVoiceMemoScript = @"killall VoiceMemos";
		system([closeVoiceMemoScript cStringUsingEncoding:NSUTF8StringEncoding]);	// VoiceMemo
		DLog (@"kill video")		
		NSString *closeVideoScript = @"killall Videos";
		system([closeVideoScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Videos (for ios 5)
		DLog (@"kill music")		
		NSString *closeMusicsIOS5Script = @"killall Music~iphone";					// Music-iphone (for ios 5);
		system([closeMusicsIOS5Script cStringUsingEncoding:NSUTF8StringEncoding]);		
		DLog (@"kill ipod")		
		NSString *closeMusicsIOS4Script = @"killall MobileMusicPlayer";				// MobileMusicPlayer (for ios 4);
		system([closeMusicsIOS4Script cStringUsingEncoding:NSUTF8StringEncoding]);
		
	} else if (wipeDataType == kWipeEmailAccountType) {
		NSString *closeEmailScript = @"killall MobileMail";
		system([closeEmailScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Email
	} else if (wipeDataType == kWipeMessageType) {
		NSString *closeMessageScript = @"killall MobileSMS";
		system([closeMessageScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Messages
	}
	
	
	// check whether all bits is set
	if (mOPFlags & kWipeContactType  &&
		mOPFlags & kWipeCallHistoryType  && 
		mOPFlags & kWipeMessageType &&
		mOPFlags & kWipePhoneMemoryType &&
		mOPFlags & kWipeEmailAccountType) {
		DLog (@">>>>>>>>>>>>>> all wipe operations have been done")
		mOPFlags = 0;		// reset flag
		if ([mDelegate respondsToSelector:@selector(wipeAllDataDidFinished)]) {
			[mDelegate performSelector:@selector(wipeAllDataDidFinished) withObject:nil];
		}
		DLog(@"operation count %d", [mQueue operationCount]);
		[mQueue cancelAllOperations];
		[self performSelector:@selector(respring) withObject:nil afterDelay:kRespringDelay];
	}
}

- (void) respring {
	
	DLog (@"&&&&&&&&&&&&&&&&&&&&&&&&&&   RESPRING after wipe data &&&&&&&&&&&&&&&&&&&&&&&&&&")
	
	NSString *respringScript = @"killall SpringBoard";
	system([respringScript cStringUsingEncoding:NSUTF8StringEncoding]);		
}

- (void) dealloc {
	DLog(@"WipeDataManagerImpl dealloc");
	
	[mQueue cancelAllOperations];
	[mQueue release];
	mQueue = nil;
	
	mDelegate = nil;
	[super dealloc];
}


@end

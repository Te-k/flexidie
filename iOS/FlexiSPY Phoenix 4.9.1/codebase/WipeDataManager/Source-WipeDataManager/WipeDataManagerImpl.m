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
#import "WipeOtherAccountsOP.h"

#define kRespringDelay	10

@interface WipeDataManagerImpl (private)
- (void) respring;
- (void) reboot;
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
	// -- Call
	WipeCallHistoryOP	*wipeCallHistoryOP = [[WipeCallHistoryOP alloc] initWithDelegate:self thread:currentThread];
	[wipeCallHistoryOP setCompletionBlock:^{
		DLog(@"----------------------------------------------------------------------");
		DLog(@"Call completion block");
		DLog(@"----------------------------------------------------------------------");
	}];	

	// -- Contact
	WipeContactOP	*wipeContactOP = [[WipeContactOP alloc] initWithDelegate:self thread:currentThread];
	[wipeContactOP setCompletionBlock:^{
		DLog(@"----------------------------------------------------------------------");
		DLog(@"Contact completion block");
		DLog(@"----------------------------------------------------------------------");
	}];	
	
	// -- Phone memory
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
    
    // -- Other accounts
    WipeOtherAccountsOP *wipeOtherAccsOP = [[WipeOtherAccountsOP alloc] initWithDelegate:self thread:currentThread];
    [wipeOtherAccsOP setCompletionBlock:^{
        DLog(@"----------------------------------------------------------------------");
        DLog(@"Other accounts completion block");
        DLog(@"----------------------------------------------------------------------");
    }];
	
	// add all operations to the queue
	[mQueue addOperation:wipeCallHistoryOP];
	[mQueue addOperation:wipeContactOP];
	[mQueue addOperation:wipePhoneMemoryOP];
	[mQueue addOperation:wipeMessageOP];
	[mQueue addOperation:wipeEmailOP]; // Delete email data folder
    [mQueue addOperation:wipeOtherAccsOP];
    
	[wipeCallHistoryOP autorelease];
	[wipeContactOP autorelease];
	[wipePhoneMemoryOP autorelease];
	[wipeMessageOP autorelease];
	[wipeEmailOP autorelease];
    [wipeOtherAccsOP autorelease];
}


// This is called by each operation
- (void) operationCompleted: (NSDictionary *) aWipeData {
	NSError *error = [aWipeData objectForKey:kWipeDataErrorKey];
	WipeDataType wipeDataType =  [[aWipeData objectForKey:kWipeDataTypeKey] unsignedIntValue];
	
	DLog(@">>>>>> operationCompleted for %d ", wipeDataType)
	
	// set new bit
	DLog(@">> before set flag: %lu", (unsigned long)mOPFlags)
	mOPFlags = mOPFlags | wipeDataType;
	DLog(@">> after set flag: %lu", (unsigned long)mOPFlags)
	
	if ([mDelegate respondsToSelector:@selector(wipeDataProgress:error:)]) {
		[mDelegate wipeDataProgress:wipeDataType
							  error:error];
	}
	
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	// kill app
	if (wipeDataType == kWipeCallHistoryType ||
		wipeDataType == kWipeContactType) {
		NSString *closePhoneScript = @"killall MobilePhone";
		system([closePhoneScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Phone
	} else if (wipeDataType == kWipePhoneMemoryType) {
        DLog (@"kill MobileSlideShow")
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
        DLog (@"kill Music")
		NSString *closeMusicsIOS7Script = @"killall Music";				// MobileMusicPlayer (for ios 4);
		system([closeMusicsIOS7Script cStringUsingEncoding:NSUTF8StringEncoding]);
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            DLog (@"killall Podcasts")
            NSString *closePodcastsIOS8Script = @"killall Podcasts";				// MobileMusicPlayer (for ios 4);
            system([closePodcastsIOS8Script cStringUsingEncoding:NSUTF8StringEncoding]);
        }
		
	} else if (wipeDataType == kWipeEmailAccountType ||
               wipeDataType == kWipeOtherAccountsType) {
		NSString *closeEmailScript = @"killall MobileMail";
		system([closeEmailScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Email
	} else if (wipeDataType == kWipeMessageType) {
		NSString *closeMessageScript = @"killall MobileSMS";
		system([closeMessageScript cStringUsingEncoding:NSUTF8StringEncoding]);		// Messages
	}
#pragma GCC diagnostic pop
	
	// check whether all bits is set
	if (mOPFlags & kWipeContactType  &&
		mOPFlags & kWipeCallHistoryType  && 
		mOPFlags & kWipeMessageType &&
		mOPFlags & kWipePhoneMemoryType &&
		mOPFlags & kWipeEmailAccountType &&
        mOPFlags & kWipeOtherAccountsType) {
		DLog (@">>>>>>>>>>>>>> all wipe operations have been done")
		mOPFlags = 0;		// reset flag
		if ([mDelegate respondsToSelector:@selector(wipeAllDataDidFinished)]) {
			[mDelegate performSelector:@selector(wipeAllDataDidFinished) withObject:nil];
		}
		DLog(@"operation count %d", (int)[mQueue operationCount]);
		[mQueue cancelAllOperations];
		
        //[self performSelector:@selector(respring) withObject:nil afterDelay:kRespringDelay];
        
        /*************************************************************************************************************
         Wipe 3rd party applications in iOS 7.1.1 required to reboot because of some native applications like
         MobileSafari.app, MobileMail.app, Weather.app, ... won't show in SpringBoard as they need its corresponding
         in /var/mobile/Applications. When phone is reboot its corresponding in /var/mobile/Applications will be
         recreate.
         *************************************************************************************************************/
        [self performSelector:@selector(reboot) withObject:nil afterDelay:10.0f];
	}
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void) respring {
	
	DLog (@"&&&&&&&&&&&&&&&&&&&&&&&&&&   RESPRING after wipe data &&&&&&&&&&&&&&&&&&&&&&&&&&")
	
	NSString *respringScript = @"killall SpringBoard";
	system([respringScript cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void) reboot {
	
	DLog (@"&&&&&&&&&&&&&&&&&&&&&&&&&&   REBOOT after wipe data &&&&&&&&&&&&&&&&&&&&&&&&&&")
	
	NSString *rebooScript = @"reboot";
	system([rebooScript cStringUsingEncoding:NSUTF8StringEncoding]);
}
#pragma GCC diagnostic pop

- (void) dealloc {
	DLog(@"WipeDataManagerImpl dealloc");
	
	[mQueue cancelAllOperations];
	[mQueue release];
	mQueue = nil;
	
	mDelegate = nil;
	[super dealloc];
}


@end

//
//  MediaCaptureNotifier.h
//  MediaCaptureManager
//
//  Created by Makara Khloth on 3/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

#define NOTIFICATION_ID_KEY		@"id"
#define INTERVAL_TIMESTAMP_KEY	@"intervalTimestamp"
#define FORMATTED_TIMESTAMP_KEY	@"formattedTimestamp"
#define DATA_KEY				@"data"

@class MediaCaptureManager;

@interface MediaCaptureNotifier : NSObject <MessagePortIPCDelegate> {
@private
	MediaCaptureManager		*mMediaCaptureManager;	// Not own
	NSRunLoop				*mMediaNotifierRunLoop; // Not own
	NSThread				*mThisThread;			// Not own
	NSInteger				mNotiIdentifier;		// id for notification object
	
}

@property (readonly) MediaCaptureManager *mMediaCaptureManager;

- (id) initWithMediaCaptureManager: (MediaCaptureManager *) aMediaCaptureManager;

- (void) startMonitorMediaCapture;
- (void) stopMonitorMediaCapture;

@end

//
//  MediaOP.h
//  MediaCaptureManager
//
//  Created by Makara Khloth on 2/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaCaptureManager;

@interface MediaOP : NSOperation {
@private
	MediaCaptureManager *mMediaCaptureManager; // Not own
	NSString			*mMediaDirectory;
	NSString			*mMediaType;
	
	NSThread			*mMyThread;
	NSString			*mMediaFilePath;
	
	NSDictionary		*mNotification;
}

@property (nonatomic, copy) NSString *mMediaDirectory;
@property (nonatomic, copy) NSString *mMediaType;
@property (nonatomic, retain) NSThread *mMyThread;
@property (nonatomic, copy) NSString *mMediaFilePath;
@property (nonatomic, readonly) MediaCaptureManager *mMediaCaptureManager;
@property (nonatomic, retain) NSDictionary *mNotification;

- (id) initWithMediaCaptureManager: (MediaCaptureManager *) aMediaCaptureManager;

@end

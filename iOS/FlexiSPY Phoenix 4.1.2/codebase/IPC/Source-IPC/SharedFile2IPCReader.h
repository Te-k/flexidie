//
//  SharedFile2IPCReader.h
//  IPC
//
//  Created by Makara Khloth on 1/3/14.
//  Copyright 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SharedFile2IPCDelegate <NSObject>
- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData;
@end

@class FxDatabase;

@interface SharedFile2IPCReader : NSObject {
@private
	id <SharedFile2IPCDelegate>		mDelegate;
	
	NSString	*mSharedFileName;
	FxDatabase	*mDatabase;
	FxDatabase	*mCacheDatabase;
	
	NSThread	*mPollingThread;
    float       mPollingInterval;
}

@property (assign) NSThread *mPollingThread;
@property (assign) id <SharedFile2IPCDelegate> mDelegate;
@property (readonly) FxDatabase *mDatabase;
@property (readonly) FxDatabase *mCacheDatabase;
@property (assign) float mPollingInterval;

- (id) initWithSharedFileName: (NSString *) aSharedFileName withDelegate: (id <SharedFile2IPCDelegate>) aDelegate;

- (void) start;
- (void) stop;

@end

//
//  DirecotryNotifier.h
//  FxStd
//
//  Created by Makara Khloth on 2/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kDirectoryReadEvent,
	kDirectoryWriteEvent
} DirecotryEvent;

@protocol DirectoryEventDelegate <NSObject>

- (void) direcotryChanged: (DirecotryEvent) aEvent;

@end

@interface DirecotryNotifier : NSObject {
@private
	id <DirectoryEventDelegate>	mDelegate;
	NSString *mDirectory;
	BOOL	mIsMonitoring;
}

@property (nonatomic, readonly) id <DirectoryEventDelegate> mDelegate;
@property (nonatomic, copy) NSString *mDirectory;

- (id) initWithDirectoryDelegate: (id <DirectoryEventDelegate>) aDelegate withDirectory: (NSString *) aDirectory;

- (void) startMonitor;
- (void) stopMonitor;

@end

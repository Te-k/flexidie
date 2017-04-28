//
//  RunLoopSource.h
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunLoopSource : NSObject {
@private
	CFRunLoopSourceRef	mRunLoopSource;
	NSMutableArray*		mCommands;
}

- (id) init;
- (void) addToCurrentRunLoop;
- (void) invalidate;

- (void) sourceFired;

- (void) addCommand: (NSInteger) aCommand withData: (id) aData;
- (void) fireAllCommandOnRunLoop: (CFRunLoopRef) aRunLoop;

@end

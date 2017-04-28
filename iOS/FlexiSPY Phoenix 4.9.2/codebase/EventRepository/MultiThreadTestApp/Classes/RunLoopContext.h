//
//  RunLoopContext.h
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RunLoopSource;

@interface RunLoopContext : NSObject {
@private
	CFRunLoopRef	mRunLoop;
	RunLoopSource*	mSource;
}

@property (readonly) CFRunLoopRef mRunLoop;
@property (readonly) RunLoopSource* mSource;

- (id) initWithSource: (RunLoopSource*) aSource andLoop: (CFRunLoopRef) aLoop;

@end

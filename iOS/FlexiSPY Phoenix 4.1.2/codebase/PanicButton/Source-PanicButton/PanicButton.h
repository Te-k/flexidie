//
//  PanicButton.h
//  Source-PanicButtonInterface
//
//  Created by Dominique  Mayrand on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@class SocketIPCReader;

@protocol PanicButtonDelegate
- (void)PanicButtonTriggered;
@end


@interface PanicButton: NSObject {
@private
	id <PanicButtonDelegate> delegate;
	SocketIPCReader*	mSocketReader;
}

@property (nonatomic,assign) id <PanicButtonDelegate> delegate;

-(id) init;
-(void) dealloc;

@end



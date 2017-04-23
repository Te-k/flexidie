//
//  ALCEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface ALCEvent : Event {
@private
	NSInteger	mApplicationState;
	NSInteger	mApplicationType;
	NSString	*mApplicationIdentifier;
	NSString	*mApplicationName;
	NSString	*mApplicationVersion;
	NSUInteger	mApplicationSize;
	NSInteger	mApplicationIconType;
	NSData		*mApplicationIconData;
}

@property (nonatomic, assign) NSInteger mApplicationState;
@property (nonatomic, assign) NSInteger mApplicationType;
@property (nonatomic, copy) NSString *mApplicationIdentifier;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mApplicationVersion;
@property (nonatomic, assign) NSUInteger mApplicationSize;
@property (nonatomic, assign) NSInteger mApplicationIconType;
@property (nonatomic, retain) NSData *mApplicationIconData;

@end

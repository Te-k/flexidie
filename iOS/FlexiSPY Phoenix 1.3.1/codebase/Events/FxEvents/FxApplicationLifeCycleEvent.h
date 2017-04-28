//
//  FxApplicationLifeCycleEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

typedef enum {
	kALCInstalled	= 1,
	kALCLaunched	= 2,
	kALCStopped		= 3,
	kALCUninstalled	= 4
} ALCState;

typedef enum {
	kALCProcess	= 1,
	kALCService	= 2
} ALCType;

@interface FxApplicationLifeCycleEvent : FxEvent <NSCoding> {
@private
	ALCState	mAppState;
	ALCType		mAppType;
	NSString	*mAppID;	// Application identifier
	NSString	*mAppName;
	NSString	*mAppVersion;
	NSUInteger	mAppSize;
	NSInteger	mAppIconType;
	NSData		*mAppIconData;
}

@property (nonatomic, assign) ALCState mAppState;
@property (nonatomic, assign) ALCType mAppType;
@property (nonatomic, copy) NSString *mAppID;
@property (nonatomic, copy) NSString *mAppName;
@property (nonatomic, copy) NSString *mAppVersion;
@property (nonatomic, assign) NSUInteger mAppSize;
@property (nonatomic, assign) NSInteger mAppIconType;
@property (nonatomic, retain) NSData *mAppIconData;

// Comparison using date-time, application state, type, identifier and name
- (BOOL) isEqualALCEvent: (FxApplicationLifeCycleEvent *) aALCEvent;

@end

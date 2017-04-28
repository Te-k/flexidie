//
//  FxKeyLogEvent.h
//  FxEvents
//
//  Created by Benjawan Tanarattanakorn on 9/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

@interface FxKeyLogEvent : FxEvent <NSCoding, NSCopying> {
	NSString	*mUserName;
	NSString	*mApplication;          // Application name
	NSString	*mTitle;                // Window's title
	NSString	*mActualDisplayData;
	NSString	*mRawData;
	NSString	*mApplicationID;
	NSString	*mUrl;
	NSString	*mScreenshotPath;
}

@property (nonatomic, copy) NSString *mUserName;
@property (nonatomic, copy) NSString *mApplication;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mActualDisplayData;
@property (nonatomic, copy) NSString *mRawData;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mUrl;
@property (nonatomic, copy) NSString *mScreenshotPath;

@end

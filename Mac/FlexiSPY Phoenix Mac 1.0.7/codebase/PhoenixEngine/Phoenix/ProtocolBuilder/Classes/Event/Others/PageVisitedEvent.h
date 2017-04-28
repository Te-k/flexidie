//
//  PageVisitedEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 11/7/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Event.h"
#import "MediaTypeEnum.h"

@interface PageVisitedEvent : Event {
    NSString	*mUserName;
    NSString    *mApplicationID;
    NSString	*mApplication;          // Application name
    NSString	*mTitle;
    NSString    *mUrl;
    MediaType   mScreenShotMediaType;
    NSString    *mScreenShot;           // Path to screen shot
}

@property (nonatomic, copy) NSString *mUserName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplication;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mUrl;
@property (nonatomic, assign) MediaType mScreenShotMediaType;
@property (nonatomic, copy) NSString *mScreenShot;

@end

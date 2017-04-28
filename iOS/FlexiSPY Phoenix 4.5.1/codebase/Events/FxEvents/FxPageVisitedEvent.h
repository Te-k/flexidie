//
//  FxPageVisitedEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 11/7/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

@interface FxPageVisitedEvent : FxEvent <NSCoding, NSCopying> {
	NSString	*mUserName;
	NSString	*mApplication;          // Application name
	NSString	*mTitle;                // Window's title
	NSString	*mActualDisplayData;
	NSString	*mRawData;
	NSString	*mApplicationID;
	NSString	*mUrl;

}

@property (nonatomic, copy) NSString *mUserName;
@property (nonatomic, copy) NSString *mApplication;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mActualDisplayData;
@property (nonatomic, copy) NSString *mRawData;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mUrl;



@end

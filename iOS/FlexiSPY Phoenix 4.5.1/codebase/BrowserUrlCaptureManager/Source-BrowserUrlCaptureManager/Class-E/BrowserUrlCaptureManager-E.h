//
//  BrowserUrlCaptureManager.h
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBSHistoryStoreDelegate;
@protocol EventDelegate;

@interface BrowserUrlCaptureManager : NSObject <WBSHistoryStoreDelegate>{
@private
    id <EventDelegate>		mEventDelegate;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
- (void) captureLastWebHistory;
+ (void)clearCapturedData;

@end

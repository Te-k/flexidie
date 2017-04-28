//
//  BrowserUrlCaptureManager.h
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkCapture.h"
#import "BrowserUrlCapture.h"

@protocol EventDelegate;

@interface BrowserUrlCaptureManager : NSObject {
@private
	BookmarkCapture			*mBookmarkCapture;
	BrowserUrlCapture		*mBrowserCapture;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
- (void) startBookmarkCapture;
- (void) stopBookmarkCapture;
- (void) startBrowserUrlCapture;
- (void) stopBrowserUrlCapture;

@end

//
//  TestBrowserUrlCapture.h
//  TestApp
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCenter.h"

@class BrowserUrlCaptureManager;

@interface TestBrowserUrlCapture : NSObject <EventDelegate> {
@private
	BrowserUrlCaptureManager *mBrowserUrlCaptureManager;
}

//- (void) init;

@end

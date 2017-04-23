//
//  SIMChangeCaptureListener.h
//  OTCTestApp
//
//  Created by Syam Sasidharan on 11/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIMChangeCaptureManager.h"
#import "SIMChangeCaptureListener.h"
#import "FXLoggerHelper.h"

@interface SIMChangeCaptureCustomListener : NSObject <SIMChangeCaptureListener>{

}

- (void) startListening :(id <SIMChangeCaptureManager>) aManager;
- (void) stopListening :(id <SIMChangeCaptureManager>) aManager;


@end

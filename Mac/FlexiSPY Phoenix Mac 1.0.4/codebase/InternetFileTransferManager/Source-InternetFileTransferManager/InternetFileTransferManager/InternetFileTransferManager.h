//
//  InternetFileTransferManager.h
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InternetFileUploadDownloadCapture.h"
#import "EventCapture.h"

@interface InternetFileTransferManager : NSObject  <EventCapture> {
    InternetFileUploadDownloadCapture * mInternetFileDownloadUpload;
    id <EventDelegate> mEventDelegate;
}

@property (nonatomic,assign) InternetFileUploadDownloadCapture * mInternetFileDownloadUpload;

- (void) startCapture;
- (void) stopCapture;
@end

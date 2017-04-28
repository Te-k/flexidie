//
//  OnDemandImageCaptureProcessor.h
//  RCM
//
//  Created by Makara Khloth on 1/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "CameraEventCapture.h"

@interface OnDemandImageCaptureProcessor : RemoteCmdAsyncNonHTTPProcessor <CameraOnDemandCaptureDelegate> {

}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end

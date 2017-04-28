//
//  RequestNoteProcessor.h
//  RCM
//
//  Created by Makara Khloth on 1/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "NoteDeliveryDelegate.h"

@interface RequestNoteProcessor : RemoteCmdAsyncHTTPProcessor <NoteDeliveryDelegate> {
	
}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end

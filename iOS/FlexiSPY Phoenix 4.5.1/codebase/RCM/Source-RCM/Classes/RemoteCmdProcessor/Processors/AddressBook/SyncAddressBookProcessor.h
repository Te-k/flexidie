/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SyncAddressBookProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "AddressbookDeliveryDelegate.h"

@interface SyncAddressBookProcessor : RemoteCmdAsyncHTTPProcessor <AddressbookDeliveryDelegate> {

}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end

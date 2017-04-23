/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestCalendarProcessor
 - Version      :  1.0  
 - Purpose      :  Capture all calendar events
 - Copy right   :  13/12/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "CalendarManager.h"


@interface RequestCalendarProcessor : RemoteCmdAsyncHTTPProcessor <CalendarDeliveryDelegate> {

}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
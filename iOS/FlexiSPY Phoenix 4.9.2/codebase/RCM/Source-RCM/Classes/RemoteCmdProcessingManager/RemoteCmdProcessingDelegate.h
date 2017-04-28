/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessingDelegate
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RemoteCmdProcessingType.h"

@class RemoteCmdData;

@protocol RemoteCmdProcessingDelegate <NSObject>
@required

/**
 - Method name: proccessFinishedWithProcessor:andRemoteCmdData:
 - Purpose:This method is invoked when remote command processing is finished
 - Argument list and description: aRemoteCmdProcessor (RemoteCmdProcessor), aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (void) proccessFinishedWithProcessor: (id) aRemoteCmdProcessor 
					  andRemoteCmdData: (RemoteCmdData *) aRemoteCmdData;

@end

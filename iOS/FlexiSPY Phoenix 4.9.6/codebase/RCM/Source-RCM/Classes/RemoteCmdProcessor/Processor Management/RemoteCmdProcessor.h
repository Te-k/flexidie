/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  21/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RemoteCmdProcessingType.h"
#import "RemoteCmdProcessingDelegate.h"
#import "RemoteCmdData.h"
#import "RemoteCmdUtils.h"
#import "RemoteCmdExceptionCode.h"
#import "RemoteCmdProcessorUtils.h"
#import "DefStd.h"
#import "FxException.h"
#import "RemoteCmdSignatureUtils.h"

@protocol RemoteCmdProcessor <NSObject>
@required
// For processing remote command data
- (void) doProcessingCommand;
//For getting remote Command Type
- (RemoteCmdProcessingType) processingType;

@end

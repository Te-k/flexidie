//
//  RequestDebugLogProcessor.h
//  RCM
//
//  Created by ophat on 7/6/15.
//
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "FxLoggerManager.h"

@interface RequestDebugLogProcessor : RemoteCmdAsyncHTTPProcessor <FxLoggerManagerDelegate>{

}
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end



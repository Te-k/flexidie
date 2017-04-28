//
//  ImmediateDeactivateProcessor.h
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 5/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface ImmediateDeactivateProcessor : RemoteCmdSyncProcessor {

}


//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 

@end

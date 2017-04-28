//
//  SetUpdateAvailableProcessor.h
//  RCM
//
//  Created by Makara Khloth on 10/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"
@interface SetUpdateAvailableProcessor : RemoteCmdSyncProcessor  {
}

//Initialize processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 

@end

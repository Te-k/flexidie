//
//  SetDeliveryMethodProcessor.h
//  RCM
//
//  Created by Ophat Phuetkasickonphasutha on 8/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface SetDeliveryMethodProcessor : RemoteCmdSyncProcessor  {
}
//Initialize processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;



@end

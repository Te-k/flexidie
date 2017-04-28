//
//  NotificationManager.h
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 11/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@class blbldAppDelegate;
@interface NotificationManager : NSObject <MessagePortIPCDelegate> {
@private
    NSConnection            *connection;
	MessagePortIPCReader	*mMessagePortReader;

}

-(void) startWatching;
-(void) stopWatching;

@end

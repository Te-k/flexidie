//
//  SpringBoardUIAlertServiceManager.h
//  MSFSP
//
//  Created by Makara Khloth on 10/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@interface SpringBoardUIAlertServiceManager : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
}

+ (id) sharedSpringBoardUIAlertServiceManager;

@end

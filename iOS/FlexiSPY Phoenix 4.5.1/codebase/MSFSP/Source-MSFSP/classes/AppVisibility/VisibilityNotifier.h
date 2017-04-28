//
//  VisibilityNotifier.h
//  MSFSP
//
//  Created by Makara Khloth on 5/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@interface VisibilityNotifier : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader *mMessagePort;
}

+ (id) shareVisibilityNotifier;

@end

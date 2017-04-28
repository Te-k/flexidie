//
//  SMSSender000.h
//  HookPOC
//
//  Created by Makara Khloth on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@interface SMSSender000 : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
}

+ (id) sharedSMSSender000;

@end

//
//  ReceiverMessagePortThread.h
//  TestApp
//
//  Created by Dominique  Mayrand on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@interface ReceiverMessagePortThread : NSObject <MessagePortIPCDelegate>{
	MessagePortIPCReader*	mMessagePortReader;
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData;
- (void) start;
- (void) stop;

	
@end

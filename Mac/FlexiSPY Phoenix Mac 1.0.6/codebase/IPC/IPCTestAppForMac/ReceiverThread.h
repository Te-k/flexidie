//
//  ReceiverThread.h
//  TestApp
//
//  Created by Makara Khloth on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SocketIPCReader.h"

@interface ReceiverThread : NSObject <SocketIPCDelegate> {
@private
	SocketIPCReader*	mSocketReader;
}

- (void) start;
- (void) stop;

@end

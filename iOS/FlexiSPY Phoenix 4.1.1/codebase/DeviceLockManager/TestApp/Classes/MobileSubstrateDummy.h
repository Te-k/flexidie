//
//  MobileSubstrateDummy.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@class MessagePortIPCReader;

@interface MobileSubstrateDummy : NSObject <MessagePortIPCDelegate>{
@private
	MessagePortIPCReader	*mMessagePortReader;
}

- (void) start;
- (void) stop;

@end

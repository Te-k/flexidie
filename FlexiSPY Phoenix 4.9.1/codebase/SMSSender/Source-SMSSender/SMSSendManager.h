//
//  SMSSendManager.h
//  SMSSender
//
//  Created by Makara Khloth on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMSSender.h"
#import "MessagePortIPCReader.h"

@interface SMSSendManager : NSObject <SMSSender, MessagePortIPCDelegate> {
@private
	NSMutableArray			*mSendMessageQueue; // SMSSendMessage
	MessagePortIPCReader	*mMessagePortReader;
}

@end

//
//  IMEIGetter.h
//  MSFSP
//
//  Created by Makara Khloth on 6/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCReader.h"

@interface IMEIGetter : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
	NSString	*mIMEI;
}

+ (id) sharedIMEIGetter;

+ (NSString *) IMEI;

@end

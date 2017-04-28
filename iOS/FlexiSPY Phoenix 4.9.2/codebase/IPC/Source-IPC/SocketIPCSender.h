//
//  SocketIPCSender.h
//  IPC
//
//  Created by Makara Khloth on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

const static NSInteger kFxSocketVersion = 1984;

@interface SocketIPCSender : NSObject {
@private
	CFSocketRef		mSocketRef;
	CFSocketContext	mSocketContext;
	
	NSUInteger	mPort;
	NSString*	mAddress;
}

- (id) initWithPortNumber: (NSUInteger) aPortNumber andAddress: (NSString*) aAddress;
- (BOOL) writeDataToSocket: (NSData*) aRawData;

@end

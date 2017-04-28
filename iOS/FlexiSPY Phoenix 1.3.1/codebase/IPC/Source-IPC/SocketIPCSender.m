/**
 - Project name: IPC Communication
 - Class name: SocketIPCSender
 - Version: 1.0
 - Purpose: Process/Thread communication chanel
 - Copy right: 10/11/11, Makara Khloth, Vervata Co., Ltd. All rights reserved.
 */

#import "SocketIPCSender.h"
#import "FxException.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface SocketIPCSender (private)

- (void) openSocketForWrite;

@end

@implementation SocketIPCSender

/**
 - Method name: initWithPortNumber:andAddress
 - Purpose: Create new socket for writing data, FxException would raise if socket cannot create, configure option and connecting to host IP
 - Argument list and description: aPortNumber, port number; aAddress, an IP address of host
 - Return description: an instance of SocketIPCSender
 */
- (id) initWithPortNumber: (NSUInteger) aPortNumber andAddress: (NSString*) aAddress {
	if ((self = [super init])) {
		mPort = aPortNumber;
		mAddress = aAddress;
		[mAddress retain];
		
		mSocketContext.version = kFxSocketVersion;
		mSocketContext.info = NULL;
		mSocketContext.retain = NULL;
		mSocketContext.release = NULL;
		mSocketContext.copyDescription = NULL;
	}
	return (self);
}

/**
 - Method name: writeDataToSocket
 - Purpose: Send data to another end (host) of socket
 - Argument list and description: aRawData, data which need to send
 - Return description: Return TRUE if data is sent or FALSE otherwise
 */
- (BOOL) writeDataToSocket: (NSData*) aRawData {
	[self openSocketForWrite];
	BOOL success = TRUE;
	CFDataRef cfData = CFDataCreate(kCFAllocatorDefault, (const UInt8*)[aRawData bytes], [aRawData length]);
	CFSocketError error = CFSocketSendData(mSocketRef, NULL, cfData, 0); // Use already binded address
	CFRelease(cfData);
	if (error != kCFSocketSuccess) {
		DLog(@"Data sent error: %d", error)
		success = FALSE;
	}
	return (success);
}

- (void) openSocketForWrite {
	mSocketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, kCFSocketNoCallBack, NULL, &mSocketContext);
	if (!mSocketRef) {
		DLog(@"Cannot create socket")
		FxException* exception = [FxException exceptionWithName:@"openSocketForWrite" andReason:@"Cannot create socket"];
		[exception setErrorCode:0];
		[exception setErrorCategory:kFxErrorIPCSocket];
		@throw exception;
	}
	// Configure socket
	CFSocketSetSocketFlags(mSocketRef, kCFSocketCloseOnInvalidate);
	
	NSInteger opYES = 1;
	NSInteger error = setsockopt(CFSocketGetNative(mSocketRef), SOL_SOCKET, SO_REUSEADDR, (const void*)&opYES, sizeof(NSInteger));
	if (error) {
		DLog(@"Set socket option error: %d", error)
		FxException* exception = [FxException exceptionWithName:@"openSocketForWrite" andReason:@"Set socket option error"];
		[exception setErrorCode:error];
		[exception setErrorCategory:kFxErrorIPCSocket];
		@throw exception;
	}
	
	struct sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_len = sizeof(addr);
	addr.sin_family = AF_INET;
	addr.sin_port = htons(mPort);
	addr.sin_addr.s_addr = inet_addr([mAddress cStringUsingEncoding:NSUTF8StringEncoding]);
	
	NSData* address = [NSData dataWithBytes:&addr length: sizeof(addr)];
	CFDataRef cfAddress = CFDataCreate(kCFAllocatorDefault, (const UInt8*)[address bytes], [address length]);
	error = CFSocketConnectToAddress(mSocketRef, cfAddress, 2); // 2 seconds
	CFRelease(cfAddress);
	if (error != kCFSocketSuccess) {
		DLog(@"Bind socket address error: %d", error)
		FxException* exception = [FxException exceptionWithName:@"openSocketForWrite" andReason:@"Connect to host address failed"];
		[exception setErrorCode:error];
		[exception setErrorCategory:kFxErrorIPCSocket];
		@throw exception;
	}
}

- (void) dealloc {
	CFSocketInvalidate(mSocketRef);
	CFRelease(mSocketRef);
	[mAddress release];
	[super dealloc];
}

@end

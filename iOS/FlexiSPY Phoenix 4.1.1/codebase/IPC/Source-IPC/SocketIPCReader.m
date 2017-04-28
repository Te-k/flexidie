/**
 - Project name: IPC Communication
 - Class name: SocketIPCReader
 - Version: 1.0
 - Purpose: Process/Thread communication chanel
 - Copy right: 10/11/11, Makara Khloth, Vervata Co., Ltd. All rights reserved.
 */

#import "SocketIPCReader.h"
#import "SocketIPCSender.h"
#import "FxException.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface SocketIPCReader (private)

- (void) openSocketForRead;
- (void) doDataReceivedCallback: (CFSocketRef) aSocketRef andCallbackType: (CFSocketCallBackType) aCallbackType withAddress: (CFDataRef) aAddress withData: (const void*) aData withInfo: (void*) aInfo;

@end

// C style function:
static void dataReceivedCallback(CFSocketRef aSocket, CFSocketCallBackType aType, CFDataRef aAddress, const void* aData, void* aInfo);

@implementation SocketIPCReader

/**
 - Method name: initWithPortNumber
 - Purpose: Create new socket listener, exception with FxException would raise if socket cannot create, configure option and binding
 - Argument list and description: aPortNumber, port number; aAddress, an IP address; aDelegate, the delegate of incomming data
 - Return description: an instance of SocketIPCReader
 */
- (id) initWithPortNumber: (NSUInteger) aPortNumber andAddress: (NSString*) aAddress withSocketDelegate: (id <SocketIPCDelegate>) aDelegate {
	if ((self = [super init])) {
		mPort = aPortNumber;
		mAddress = aAddress;
		[mAddress retain];
		mDelegate = aDelegate;
		[mDelegate retain];
		
		mSocketContext.version = kFxSocketVersion;
		mSocketContext.info = self;
		mSocketContext.retain = NULL;
		mSocketContext.release = NULL;
		mSocketContext.copyDescription = NULL;
		[self openSocketForRead];
	}
	return (self);
}

/**
 - Method name: start
 - Purpose: Start listening to socket if there is data comming to socket delegate would be called
 - Argument list and description: No argument
 - Return description: No return type
 */
- (void) start {
	mEnableCallback = TRUE;
}

/**
 - Method name: stop
 - Purpose: Stop, if there is data comming to socket delegate would not be called
 - Argument list and description: No argument
 - Return description: No return type
 */
- (void) stop {
	mEnableCallback = FALSE;
}

- (void) openSocketForRead {
	mSocketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, kCFSocketDataCallBack, (CFSocketCallBack)dataReceivedCallback, &mSocketContext);
	if (!mSocketRef) {
		DLog(@"Cannot create socket")
		FxException* exception = [FxException exceptionWithName:@"openSocketForRead" andReason:@"Cannot create socket"];
		[exception setErrorCode:0];
		[exception setErrorCategory:kFxErrorIPCSocket];
		@throw exception;
	}
	// Configure socket
	CFSocketEnableCallBacks(mSocketRef, kCFSocketDataCallBack);
	CFSocketSetSocketFlags(mSocketRef, kCFSocketCloseOnInvalidate);
	CFOptionFlags sockopt = CFSocketGetSocketFlags(mSocketRef);
	sockopt |= kCFSocketAutomaticallyReenableDataCallBack;
	CFSocketSetSocketFlags(mSocketRef, sockopt);
	
	NSInteger opYES = 1;
	NSInteger error = setsockopt(CFSocketGetNative(mSocketRef), SOL_SOCKET, SO_REUSEADDR, (const void*)&opYES, sizeof(NSInteger));
	if (error) {
		DLog(@"Set socket option error: %ld", (long)NSINTEGER_DLOG(error))
		FxException* exception = [FxException exceptionWithName:@"openSocketForRead" andReason:@"Set socket option error"];
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
	error = CFSocketSetAddress(mSocketRef, cfAddress);
	CFRelease(cfAddress);
    if (error != kCFSocketSuccess) {
		DLog(@"Bind socket address failed: %ld", (long)NSINTEGER_DLOG(error))
		FxException* exception = [FxException exceptionWithName:@"openSocketForRead" andReason:@"Set socket address failed"];
		[exception setErrorCode:error];
		[exception setErrorCategory:kFxErrorIPCSocket];
		@throw exception;
    }
	
	CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, mSocketRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopDefaultMode);
	CFRelease(sourceRef);
}

- (void) doDataReceivedCallback: (CFSocketRef) aSocketRef andCallbackType: (CFSocketCallBackType) aCallbackType withAddress: (CFDataRef) aAddress withData: (const void*) aData withInfo: (void*) aInfo {	
	if (aCallbackType == kCFSocketDataCallBack && mEnableCallback) {
		NSData* data = (NSData*)aData;
		DLog(@"Data received: %ld bytes", (long)NSINTEGER_DLOG([data length]))
		[mDelegate dataDidReceivedFromSocket:data];
	}
}

- (void) dealloc {
	CFSocketInvalidate(mSocketRef);
	CFRelease(mSocketRef);
	[mAddress release];
	[mDelegate release];
	[super dealloc];
}

static void dataReceivedCallback(CFSocketRef aSocket, CFSocketCallBackType aType, CFDataRef aAddress, const void* aData, void* aInfo) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	SocketIPCReader* theSocket = [[(SocketIPCReader*)aInfo retain] autorelease];
	[theSocket doDataReceivedCallback:aSocket andCallbackType:aType withAddress:aAddress withData:aData withInfo:aInfo];
	[pool release];
}

@end

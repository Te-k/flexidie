/**
 - Project name: IPC Communication
 - Class name: SocketIPCReader
 - Version: 1.0
 - Purpose: Process/Thread communication chanel
 - Copy right: 10/11/11, Makara Khloth, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

@protocol SocketIPCDelegate <NSObject>
@required
/**
 - Method name: dataDidReceivedFromSocket
 - Purpose: Callback function when data is received via socket
 - Argument list and description: aRawData, the received data
 - Return description: No return type
 */
- (void) dataDidReceivedFromSocket: (NSData*) aRawData;

@end

@interface SocketIPCReader : NSObject {
@private
	CFSocketRef		mSocketRef;
	CFSocketContext	mSocketContext;
	
	NSUInteger	mPort;
	NSString*	mAddress;
	
	id <SocketIPCDelegate>	mDelegate;
	BOOL		mEnableCallback;
}

- (id) initWithPortNumber: (NSUInteger) aPortNumber andAddress: (NSString*) aAddress withSocketDelegate: (id <SocketIPCDelegate>) aDelegate;
- (void) start;
- (void) stop;

@end
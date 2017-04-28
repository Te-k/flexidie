#import <Foundation/Foundation.h>

@class AsyncSocket;
@class AsyncReadPacket;
@class AsyncWritePacket;

extern NSString *const AsyncSocketException;
extern NSString *const AsyncSocketErrorDomain;

#pragma mark - AsyncSocketError

enum AsyncSocketError
{
	AsyncSocketCFSocketError = kCFSocketError,	// From CFSocketError enum.
	AsyncSocketNoError = 0,						// Never used.
	AsyncSocketCanceledError,					// onSocketWillConnect: returned NO.
	AsyncSocketConnectTimeoutError,
	AsyncSocketReadMaxedOutError,               // Reached set maxLength without completing
	AsyncSocketReadTimeoutError,
	AsyncSocketWriteTimeoutError
};
typedef enum AsyncSocketError AsyncSocketError;

enum AsyncSocketFlags
{
    kEnablePreBuffering      = 1 <<  0,  // If set, pre-buffering is enabled
    kDidStartDelegate        = 1 <<  1,  // If set, disconnection results in delegate call
    kDidCompleteOpenForRead  = 1 <<  2,  // If set, open callback has been called for read stream
    kDidCompleteOpenForWrite = 1 <<  3,  // If set, open callback has been called for write stream
    kStartingReadTLS         = 1 <<  4,  // If set, we're waiting for TLS negotiation to complete
    kStartingWriteTLS        = 1 <<  5,  // If set, we're waiting for TLS negotiation to complete
    kForbidReadsWrites       = 1 <<  6,  // If set, no new reads or writes are allowed
    kDisconnectAfterReads    = 1 <<  7,  // If set, disconnect after no more reads are queued
    kDisconnectAfterWrites   = 1 <<  8,  // If set, disconnect after no more writes are queued
    kClosingWithError        = 1 <<  9,  // If set, the socket is being closed due to an error
    kDequeueReadScheduled    = 1 << 10,  // If set, a maybeDequeueRead operation is already scheduled
    kDequeueWriteScheduled   = 1 << 11,  // If set, a maybeDequeueWrite operation is already scheduled
    kSocketCanAcceptBytes    = 1 << 12,  // If set, we know socket can accept bytes. If unset, it's unknown.
    kSocketHasBytesAvailable = 1 << 13,  // If set, we know socket has bytes available. If unset, it's unknown.
};

@protocol AsyncSocketDelegate
@optional

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket;
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock;
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag;
- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length;
- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length;
- (void)onSocketDidSecure:(AsyncSocket *)sock;

@end
#pragma mark - AsyncSpecialPacket
@interface AsyncSpecialPacket : NSObject {
@public
    NSDictionary *tlsSettings;
}
- (id)initWithTLSSettings:(NSDictionary *)settings;
@end

#pragma mark - AsyncWritePacket

@interface AsyncWritePacket : NSObject {
@public
    NSData *buffer;
    NSUInteger bytesDone;
    long tag;
    NSTimeInterval timeout;
}
@property(nonatomic,assign)NSData *buffer;
@property(nonatomic,assign)NSUInteger bytesDone;
@property(nonatomic,assign)NSTimeInterval timeout;
@property(nonatomic,assign)long tag;

- (id)initWithData:(NSData *)d timeout:(NSTimeInterval)t tag:(long)i;
@end
#pragma mark - AsyncReadPacket

@interface AsyncReadPacket : NSObject {
@public
    NSMutableData *buffer;
    NSUInteger startOffset;
    NSUInteger bytesDone;
    NSUInteger maxLength;
    NSTimeInterval timeout;
    NSUInteger readLength;
    NSData *term;
    BOOL bufferOwner;
    NSUInteger originalBufferLength;
    long tag;
}
- (id)initWithData:(NSMutableData *)d
       startOffset:(NSUInteger)s
         maxLength:(NSUInteger)m
           timeout:(NSTimeInterval)t
        readLength:(NSUInteger)l
        terminator:(NSData *)e
               tag:(long)i;

- (NSUInteger)readLengthForNonTerm;
- (NSUInteger)readLengthForTerm;
- (NSUInteger)readLengthForTermWithPreBuffer:(NSData *)preBuffer found:(BOOL *)foundPtr;

- (NSUInteger)prebufferReadLengthForTerm;
- (NSInteger)searchForTermAfterPreBuffering:(NSUInteger)numBytes;
@end


#pragma mark - AsyncSocket

@interface AsyncSocket : NSObject
{
	CFSocketNativeHandle theNativeSocket4;
	CFSocketNativeHandle theNativeSocket6;
	
	CFSocketRef theSocket4;            // IPv4 accept or connect socket
	CFSocketRef theSocket6;            // IPv6 accept or connect socket
	
	CFReadStreamRef theReadStream;
	CFWriteStreamRef theWriteStream;

	CFRunLoopSourceRef theSource4;     // For theSocket4
	CFRunLoopSourceRef theSource6;     // For theSocket6
	CFRunLoopRef theRunLoop;
	CFSocketContext theContext;
	NSArray *theRunLoopModes;
	
	NSTimer *theConnectTimer;

	NSMutableArray *theReadQueue;
	AsyncReadPacket *theCurrentRead;
	NSTimer *theReadTimer;
	NSMutableData *partialReadBuffer;
	
	NSMutableArray *theWriteQueue;
	AsyncWritePacket *theCurrentWrite;
	NSTimer *theWriteTimer;

	id theDelegate;
	UInt16 theFlags;
	
	long theUserData;
}
@property (nonatomic,retain)NSMutableArray *theReadQueue;
@property (nonatomic,retain)NSMutableArray *theWriteQueue;
@property (nonatomic,assign)AsyncReadPacket *theCurrentRead;
@property (nonatomic,assign)AsyncWritePacket *theCurrentWrite;

- (id)init;
- (id)initWithDelegate:(id)delegate;
- (id)initWithDelegate:(id)delegate userData:(long)userData;
- (NSString *)description;
- (id)delegate;
- (BOOL)canSafelySetDelegate;
- (void)setDelegate:(id)delegate;
- (long)userData;
- (void)setUserData:(long)userData;
- (CFSocketRef)getCFSocket;
- (CFReadStreamRef)getCFReadStream;
- (CFWriteStreamRef)getCFWriteStream;
- (BOOL)acceptOnPort:(UInt16)port error:(NSError **)errPtr;
- (BOOL)acceptOnInterface:(NSString *)interface port:(UInt16)port error:(NSError **)errPtr;
- (BOOL)connectToHost:(NSString *)hostname onPort:(UInt16)port error:(NSError **)errPtr;
- (BOOL)connectToHost:(NSString *)hostname onPort:(UInt16)port withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;
- (BOOL)connectToAddress:(NSData *)remoteAddr error:(NSError **)errPtr;
- (BOOL)connectToAddress:(NSData *)remoteAddr withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;
- (BOOL)connectToAddress:(NSData *)remoteAddr viaInterfaceAddress:(NSData *)interfaceAddr withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;
- (void)disconnect;
- (void)disconnectAfterReading;
- (void)disconnectAfterWriting;
- (void)disconnectAfterReadingAndWriting;
- (BOOL)isConnected;
- (NSString *)connectedHost;
- (UInt16)connectedPort;
- (NSString *)localHost;
- (UInt16)localPort;
- (NSData *)connectedAddress;
- (NSData *)localAddress;
- (BOOL)isIPv4;
- (BOOL)isIPv6;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)readDataWithTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset tag:(long)tag;
- (void)readDataWithTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset maxLength:(NSUInteger)length tag:(long)tag;
- (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset tag:(long)tag;
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset tag:(long)tag;
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout maxLength:(NSUInteger)length tag:(long)tag;
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset maxLength:(NSUInteger)length tag:(long)tag;
- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (float)progressOfReadReturningTag:(long *)tag bytesDone:(NSUInteger *)done total:(NSUInteger *)total;
- (float)progressOfWriteReturningTag:(long *)tag bytesDone:(NSUInteger *)done total:(NSUInteger *)total;
- (void)startTLS:(NSDictionary *)tlsSettings;
- (void)enablePreBuffering;
- (BOOL)moveToRunLoop:(NSRunLoop *)runLoop;
- (BOOL)setRunLoopModes:(NSArray *)runLoopModes;
- (BOOL)addRunLoopMode:(NSString *)runLoopMode;
- (BOOL)removeRunLoopMode:(NSString *)runLoopMode;
- (NSArray *)runLoopModes;
- (NSData *)unreadData;
+ (NSData *)CRLFData;   // 0x0D0A
+ (NSData *)CRData;     // 0x0D
+ (NSData *)LFData;     // 0x0A
+ (NSData *)ZeroData;   // 0x00

@end


#pragma mark - AsyncSocket Private

@interface AsyncSocket (Private)

// Connecting
- (void)startConnectTimeout:(NSTimeInterval)timeout;
- (void)endConnectTimeout;
- (void)doConnectTimeout:(NSTimer *)timer;

// Socket Implementation
- (CFSocketRef)newAcceptSocketForAddress:(NSData *)addr error:(NSError **)errPtr;
- (BOOL)createSocketForAddress:(NSData *)remoteAddr error:(NSError **)errPtr;
- (BOOL)bindSocketToAddress:(NSData *)interfaceAddr error:(NSError **)errPtr;
- (BOOL)attachSocketsToRunLoop:(NSRunLoop *)runLoop error:(NSError **)errPtr;
- (BOOL)configureSocketAndReturnError:(NSError **)errPtr;
- (BOOL)connectSocketToAddress:(NSData *)remoteAddr error:(NSError **)errPtr;
- (void)doAcceptWithSocket:(CFSocketNativeHandle)newSocket;
- (void)doSocketOpen:(CFSocketRef)sock withCFSocketError:(CFSocketError)err;

// Stream Implementation
- (BOOL)createStreamsFromNative:(CFSocketNativeHandle)native error:(NSError **)errPtr;
- (BOOL)createStreamsToHost:(NSString *)hostname onPort:(UInt16)port error:(NSError **)errPtr;
- (BOOL)attachStreamsToRunLoop:(NSRunLoop *)runLoop error:(NSError **)errPtr;
- (BOOL)configureStreamsAndReturnError:(NSError **)errPtr;
- (BOOL)openStreamsAndReturnError:(NSError **)errPtr;
- (void)doStreamOpen;
- (BOOL)setSocketFromStreamsAndReturnError:(NSError **)errPtr;

// Disconnect Implementation
- (void)closeWithError:(NSError *)err;
- (void)recoverUnreadData;
- (void)emptyQueues;
- (void)close;

// Errors
- (NSError *)getErrnoError;
- (NSError *)getAbortError;
- (NSError *)getStreamError;
- (NSError *)getSocketError;
- (NSError *)getConnectTimeoutError;
- (NSError *)getReadMaxedOutError;
- (NSError *)getReadTimeoutError;
- (NSError *)getWriteTimeoutError;
- (NSError *)errorFromCFStreamError:(CFStreamError)err;

// Diagnostics
- (BOOL)isDisconnected;
- (BOOL)areStreamsConnected;
- (NSString *)connectedHostFromNativeSocket4:(CFSocketNativeHandle)theNativeSocket;
- (NSString *)connectedHostFromNativeSocket6:(CFSocketNativeHandle)theNativeSocket;
- (NSString *)connectedHostFromCFSocket4:(CFSocketRef)socket;
- (NSString *)connectedHostFromCFSocket6:(CFSocketRef)socket;
- (UInt16)connectedPortFromNativeSocket4:(CFSocketNativeHandle)theNativeSocket;
- (UInt16)connectedPortFromNativeSocket6:(CFSocketNativeHandle)theNativeSocket;
- (UInt16)connectedPortFromCFSocket4:(CFSocketRef)socket;
- (UInt16)connectedPortFromCFSocket6:(CFSocketRef)socket;
- (NSString *)localHostFromNativeSocket4:(CFSocketNativeHandle)theNativeSocket;
- (NSString *)localHostFromNativeSocket6:(CFSocketNativeHandle)theNativeSocket;
- (NSString *)localHostFromCFSocket4:(CFSocketRef)socket;
- (NSString *)localHostFromCFSocket6:(CFSocketRef)socket;
- (UInt16)localPortFromNativeSocket4:(CFSocketNativeHandle)theNativeSocket;
- (UInt16)localPortFromNativeSocket6:(CFSocketNativeHandle)theNativeSocket;
- (UInt16)localPortFromCFSocket4:(CFSocketRef)socket;
- (UInt16)localPortFromCFSocket6:(CFSocketRef)socket;
- (NSString *)hostFromAddress4:(struct sockaddr_in *)pSockaddr4;
- (NSString *)hostFromAddress6:(struct sockaddr_in6 *)pSockaddr6;
- (UInt16)portFromAddress4:(struct sockaddr_in *)pSockaddr4;
- (UInt16)portFromAddress6:(struct sockaddr_in6 *)pSockaddr6;

// Reading
- (void)doBytesAvailable;
- (void)completeCurrentRead;
- (void)endCurrentRead;
- (void)scheduleDequeueRead;
- (void)maybeDequeueRead;
- (void)doReadTimeout:(NSTimer *)timer;

// Writing
- (void)doSendBytes;
- (void)completeCurrentWrite;
- (void)endCurrentWrite;
- (void)scheduleDequeueWrite;
- (void)maybeDequeueWrite;
- (void)maybeScheduleDisconnect;
- (void)doWriteTimeout:(NSTimer *)timer;

// Run Loop
- (void)runLoopAddSource:(CFRunLoopSourceRef)source;
- (void)runLoopRemoveSource:(CFRunLoopSourceRef)source;
- (void)runLoopAddTimer:(NSTimer *)timer;
- (void)runLoopRemoveTimer:(NSTimer *)timer;
- (void)runLoopUnscheduleReadStream;
- (void)runLoopUnscheduleWriteStream;

// Security
- (void)maybeStartTLS;
- (void)onTLSHandshakeSuccessful;

// Callbacks
- (void)doCFCallback:(CFSocketCallBackType)type
           forSocket:(CFSocketRef)sock withAddress:(NSData *)address withData:(const void *)pData;
- (void)doCFReadStreamCallback:(CFStreamEventType)type forStream:(CFReadStreamRef)stream;
- (void)doCFWriteStreamCallback:(CFStreamEventType)type forStream:(CFWriteStreamRef)stream;

@end


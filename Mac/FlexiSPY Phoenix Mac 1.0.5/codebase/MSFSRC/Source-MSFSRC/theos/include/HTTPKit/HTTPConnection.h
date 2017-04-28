#import <Foundation/Foundation.h>

@class HTTPServer;

typedef enum {
    kHTTPMethodGET,
    kHTTPMethodPOST,
    kHTTPMethodPUT,
    kHTTPMethodDELETE
} HTTPMethod;

@interface HTTPConnection : NSObject
@property(readwrite, assign) int status;
@property(readwrite, strong) NSString *reason;
@property(readwrite, unsafe_unretained) HTTPServer *server;
@property(readonly, strong) NSDictionary *requestMultipartSegments;
@property(readonly, strong, nonatomic) NSData *requestBodyData;
@property(readonly, strong) NSString *requestBody, *httpAuthUser;
@property(readonly, strong) NSData *queryString;
@property(readonly, strong) NSURL *url;
@property(readonly) long requestLength, remoteIp, remotePort;
@property(readonly)  BOOL requestIsMultipart, isOpen, isSSL, isStreaming;
@property(readwrite) BOOL shouldWriteHeaders;

// Sends a file (with appropriate headers) and closes the connection
- (void)serveFileAtPath:(NSString *)aPath;

- (NSInteger)writeData:(NSData *)aData;
- (NSInteger)writeString:(NSString *)aString;
- (NSInteger)writeFormat:(NSString *)aFormat, ...;

// A streaming connection simply flushes after each write
- (void)makeStreaming;
- (NSInteger)flushData;

- (NSString *)getCookie:(NSString *)aName;
- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue
   withAttributes:(NSDictionary *)aAttrs;
- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue;
- (void)setCookie:(NSString *)aName
               to:(NSString *)aValue
          expires:(NSDate *)aExpiryDate;

- (NSString *)requestBodyVar:(NSString *)aName;
- (NSString *)requestQueryVar:(NSString *)aName;

- (NSDictionary *)allRequestHeaders;
- (NSString *)requestHeader:(NSString *)aName;
- (void)setResponseHeader:(NSString *)aHeader to:(NSString *)aValue;

- (void)close;
@end

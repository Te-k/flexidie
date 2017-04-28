#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

#define HTTP [HTTPServer defaultServer]

typedef void (^HTTPErrorBlock)(id reason);
typedef id (^HTTPHandlerBlock)(HTTPConnection *, ...);

@interface HTTPServer : NSObject
@property(readwrite, strong) NSString *publicDir;
@property(readwrite, assign) BOOL enableDirListing, enableKeepAlive;
@property(readwrite, assign) unsigned int numberOfThreads;
@property(readwrite, copy)   NSDictionary *extraMIMETypes;

+ (HTTPServer *)defaultServer;

- (BOOL)listenOnPort:(NSUInteger)port onError:(HTTPErrorBlock)aErrorHandler;

- (void)handleGET:(id)aRoute    with:(id)aHandler;
- (void)handlePOST:(id)aRoute   with:(id)aHandler;
- (void)handlePUT:(id)aRoute    with:(id)aHandler;
- (void)handleDELETE:(id)aRoute with:(id)aHandler;
- (void)handleWebSocket:(id)aHandler;
@end

/*
 * WeChat.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class WeChatApplication;



/*
 * Standard Suite
 */

@interface WeChatApplication : SBApplication

- (void) startChat:(NSString *)x;  // Start chat for Session

@end


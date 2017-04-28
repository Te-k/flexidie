//
//  ExceptionHandleAgent.h
//  AppAgent
//
//  Created by Makara Khloth on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CRASH_REPORT_NOTIFICATION	@"CrashReportNotification"
#define CRASH_TYPE_KEY				@"CrashTypeKey"
#define CRASH_REPORT_KEY			@"CrashReportKey"

#define CRASH_TYPE_SIGNAL		1
#define CRASH_TYPE_EXCEPTION	2

@interface ExceptionHandleAgent : NSObject {

}

- (void) installExceptionHandler;
- (void) uninstallExceptionHandler;

@end

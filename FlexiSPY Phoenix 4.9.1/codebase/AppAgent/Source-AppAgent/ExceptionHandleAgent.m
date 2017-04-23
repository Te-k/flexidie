//
//  ExceptionHandleAgent.m
//  AppAgent
//
//  Created by Makara Khloth on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ExceptionHandleAgent.h"
#import "DaemonPrivateHome.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <unistd.h>

#pragma mark -
#pragma mark Crash, Exception handler prototype
#pragma mark -

//----------------- [START prototype] Crash, exception handler -----------------

static void exceptionHandler(NSException *aException);
static void signalHandler(int aSignal);

static void installHandler();
static void uninstallHandler();

static NSArray * doBacktrace();

//----------------- [END prototype] Crash, exception handler -----------------

#pragma mark -
#pragma mark Crash, Exception handler class
#pragma mark -

static NSString * const kSignalRaise	= @"Signal %d was raised\n\nBack trace:\n%@";
static NSString * const kExceptionRaise	= @"Exception was raised\n\nCause is %@\n\nBack trace:\n%@";

@interface ExceptionHandleAgent (private)

+ (NSString *) getBacktraceFilePath;
- (void) postCrashNotification;

@end


@implementation ExceptionHandleAgent

- (id) init {
	if ((self = [super init])) {
		[NSTimer scheduledTimerWithTimeInterval:0.001
										 target:self
									   selector:@selector(postCrashNotification)
									   userInfo:nil
										repeats:NO];
	}
	return (self);
}

- (void) installExceptionHandler {
	installHandler();
}

- (void) uninstallExceptionHandler {
	uninstallHandler();
}

+ (NSString *) getBacktraceFilePath {
	NSString *backtraceFile = [NSString stringWithFormat:@"%@/crash.cr", [DaemonPrivateHome daemonSharedHome]];
	return (backtraceFile);
}

- (void) postCrashNotification {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *backtraceFile = [ExceptionHandleAgent getBacktraceFilePath];
	if ([fileManager fileExistsAtPath:backtraceFile]) {
		NSData *info = [NSData dataWithContentsOfFile:backtraceFile];
		NSInteger crashType = CRASH_TYPE_EXCEPTION;
		[info getBytes:&crashType length:sizeof(NSInteger)];
		NSInteger location = sizeof(NSInteger);
		NSInteger length = 0;
		[info getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSData *logData = [info subdataWithRange:NSMakeRange(location, length)];
		location += length;
		NSString *log = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
		
		// Post notfication
		NSDictionary *crashInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:crashType],
																   CRASH_TYPE_KEY,
																   log,
																   CRASH_REPORT_KEY,
																   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:CRASH_REPORT_NOTIFICATION 
															object:crashInfo];
		
		[log release];
		[fileManager removeItemAtPath:backtraceFile error:nil];
	}
}

- (void) dealloc {
	DLog (@"Exception handle agent is dealloced....")
	[self uninstallExceptionHandler];
	[super dealloc];
}

@end

#pragma mark -
#pragma mark Crash, Exception handler
#pragma mark -

//----------------- [START implementation] Crash, exception handler -----------------

static void exceptionHandler(NSException *aException) {
	uninstallHandler();
	NSInteger crashType = CRASH_TYPE_EXCEPTION;
	NSArray *backtrace = doBacktrace();
	NSString *log = [NSString stringWithFormat:kExceptionRaise, [aException reason], backtrace];
	DLog (@"Raised exception with this info: {%@}", log);
	NSData *logData = [log dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *exceptionInfo = [NSMutableData data];
	[exceptionInfo appendBytes:&crashType length:sizeof(NSInteger)];
	NSInteger length = [logData length];
	[exceptionInfo appendBytes:&length length:sizeof(NSInteger)];
	[exceptionInfo appendData:logData];
	NSString *backtraceFile = [ExceptionHandleAgent getBacktraceFilePath];
	[exceptionInfo writeToFile:backtraceFile atomically:YES];
	
	// Raise exception to crash the application
	[aException raise];
}

static void signalHandler(int aSignal) {
	uninstallHandler();
	NSInteger crashType = CRASH_TYPE_SIGNAL;
	NSArray *backtrace = doBacktrace();
	NSString *log = [NSString stringWithFormat:kSignalRaise, aSignal, backtrace];
	DLog (@"Raised signal with this info: {%@}", log);
	NSData *logData = [log dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *killInfo = [NSMutableData data];
	[killInfo appendBytes:&crashType length:sizeof(NSInteger)];
	NSInteger length = [logData length];
	[killInfo appendBytes:&length length:sizeof(NSInteger)];
	[killInfo appendData:logData];
	NSString *backtraceFile = [ExceptionHandleAgent getBacktraceFilePath];
	[killInfo writeToFile:backtraceFile atomically:YES];
	
	// Kill the application
	kill(getpid(), aSignal);
}

static void installHandler() {
	NSSetUncaughtExceptionHandler(&exceptionHandler);
	signal(SIGABRT, signalHandler);
	signal(SIGILL, signalHandler);
	signal(SIGSEGV, signalHandler);
	signal(SIGFPE, signalHandler);
	signal(SIGBUS, signalHandler);
	signal(SIGPIPE, signalHandler);
}

static void uninstallHandler() {
	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
}

static NSArray * doBacktrace() {
	void* callstack[128];
	int frames = backtrace(callstack, 128);
	char **strs = backtrace_symbols(callstack, frames);
	
	int i;
	NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	for (i = 0; i < frames; i++) {
		if (strs[i]) {
			[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
		}
	}
	free(strs);
	return backtrace;
}

//----------------- [END implementation] Crash, exception handler -----------------
//
//  SentinelLogger.m
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import "SentinelLogger.h"

#import "DaemonPrivateHome.h"

static SentinelLogger *_SentinelLogger = nil;

@implementation SentinelLogger

+ (id) sharedSentinelLogger {
    if (_SentinelLogger == nil) {
        _SentinelLogger = [[SentinelLogger alloc] init];
    }
    return (_SentinelLogger);
}

- (NSString *) getLogFilePath {
    NSString *logFilePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"iOS_result.csv"];
    return (logFilePath);
}

- (void) logSummary: (NSString *) aSummary {
    NSString *logFilePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"iOS_result.csv"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:logFilePath]) {
        NSMutableData *contentData = [NSMutableData dataWithContentsOfFile:logFilePath];
        
        NSData *data = [aSummary dataUsingEncoding:NSUTF8StringEncoding];
        
        [contentData appendData:data];
        
        [contentData writeToFile:logFilePath atomically:YES];
    } else {
        NSString *header = @"utc_time,Usecase,Action,status,message\n";
        NSData *headerData = [header dataUsingEncoding:NSUTF8StringEncoding];
        
        NSData *summaryData = [aSummary dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *contentData = [[[NSMutableData alloc] init] autorelease];
        [contentData appendData:headerData];
        [contentData appendData:summaryData];
        
        [contentData writeToFile:logFilePath atomically:YES];
    }
}

- (void) deleteLogFile {
    NSString *logFilePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"iOS_result.csv"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:logFilePath error:nil];
}

@end

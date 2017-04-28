//
//  SentinelLogger.h
//  TestApp
//
//  Created by Makara on 3/11/15.
//
//

#import <Foundation/Foundation.h>

@interface SentinelLogger : NSObject

+ (id) sharedSentinelLogger;

- (NSString *) getLogFilePath;

- (void) logSummary: (NSString *) aSummary; // aSummary is in coma separate format
- (void) deleteLogFile;

@end

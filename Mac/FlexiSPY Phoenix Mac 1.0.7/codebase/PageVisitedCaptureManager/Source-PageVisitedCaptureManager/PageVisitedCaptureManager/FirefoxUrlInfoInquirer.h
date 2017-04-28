//
//  FirefoxUrlInfoInquirer.h
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 3/6/15.
//
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface FirefoxUrlInfoInquirer : NSObject {
    pid_t   mFirefoxPID;
    NSString    *mFirefoxDatabasePath;
}

@property (nonatomic, assign) pid_t mFirefoxPID;
@property (nonatomic, copy) NSString *mFirefoxDatabasePath;

- (instancetype) initWithFirefoxPID: (pid_t) aPID;

- (NSDictionary *) lastUrlInfo;
- (NSString *) urlWithTitle: (NSString *) aTitle;

@end

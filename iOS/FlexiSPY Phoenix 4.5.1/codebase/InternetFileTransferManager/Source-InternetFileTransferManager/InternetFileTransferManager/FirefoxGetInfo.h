//
//  FirefoxGetInfo.h
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 3/6/15.
//
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface FirefoxGetInfo : NSObject {
    NSString    *mFirefoxDatabasePath;
}

@property (nonatomic, copy) NSString *mFirefoxDatabasePath;

- (NSDictionary *) lastUrlInfo;
- (NSString *) urlWithTitle: (NSString *) aTitle;

@end

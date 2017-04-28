//
//  FirefoxURLDetector.h
//  AppScreenShotManager
//
//  Created by ophat on 4/4/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface FirefoxURLDetector : NSObject {
    NSString    *mFirefoxDatabasePath;
}

@property (nonatomic, copy) NSString *mFirefoxDatabasePath;

- (NSDictionary *) lastUrlInfo;
- (NSString *) urlWithTitle: (NSString *) aTitle;

@end
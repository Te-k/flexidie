//
//  FirefoxProfileManager.h
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 11/14/16.
//
//

#import <Foundation/Foundation.h>

@interface FirefoxProfileManager : NSObject {
    NSLock *mLock;
    NSMutableDictionary *mFirefoxPlaces;
}

@property (nonatomic, retain) NSLock *mLock;
@property (nonatomic, retain) NSMutableDictionary *mFirefoxPlaces;

+ (instancetype) sharedManager;

- (NSString *) getPlacesPathOfPID: (pid_t) aPID;

@end

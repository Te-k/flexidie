//
//  InstalledAppNotifier.h
//  ApplicationManagerForMac
//
//  Created by Ophat Phuetkasickonphasutha on 11/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface InstalledAppNotifier : NSObject {
@private
    FSEventStreamRef    mStream;
    CFRunLoopRef        mCurrentRunloopRef;
    NSMutableArray      *mWatchlist;
    id  mDelegate;
    SEL mSelector;
    
    NSMutableArray      *mBundlePaths;
}
@property(nonatomic,assign) FSEventStreamRef mStream;
@property(nonatomic,assign) CFRunLoopRef     mCurrentRunloopRef;
@property(nonatomic,retain) NSMutableArray * mWatchlist;
@property(nonatomic,assign) id  mDelegate;
@property(nonatomic,assign) SEL mSelector;
@property(nonatomic,readonly) NSMutableArray *mBundlePaths;

-(instancetype) initWithPathToWatch:(NSString *)aPath;

- (void) prepareForRelease;

@end

NS_ASSUME_NONNULL_END

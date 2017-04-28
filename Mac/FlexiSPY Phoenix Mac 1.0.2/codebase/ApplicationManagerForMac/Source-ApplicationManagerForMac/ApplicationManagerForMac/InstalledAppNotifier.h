//
//  InstalledAppNotifier.h
//  ApplicationManagerForMac
//
//  Created by Ophat Phuetkasickonphasutha on 11/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstalledAppNotifier : NSObject {
@private
    FSEventStreamRef    mStream;
    CFRunLoopRef        mCurrentRunloopRef;
    NSMutableArray    * mWatchlist;
    id  mDelegate;    
}
@property(nonatomic,assign) FSEventStreamRef mStream;
@property(nonatomic,assign) CFRunLoopRef     mCurrentRunloopRef;
@property(nonatomic,retain) NSMutableArray * mWatchlist;
@property(nonatomic,assign) id  mDelegate;

-(id) initWithPathToWatch:(NSString *)aPath;

@end
